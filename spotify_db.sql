ROLLBACK;

BEGIN;


DROP TABLE IF EXISTS Playlist_Skladba CASCADE;
DROP TABLE IF EXISTS Playlist CASCADE;
DROP TABLE IF EXISTS Historia_Pocuvania CASCADE;
DROP TABLE IF EXISTS Skladba CASCADE;
DROP TABLE IF EXISTS Album CASCADE;
DROP TABLE IF EXISTS Pouzivatel CASCADE;
DROP TABLE IF EXISTS Predplatne CASCADE;
DROP TABLE IF EXISTS Umelec CASCADE;
DROP TABLE IF EXISTS Zaner CASCADE;

DROP TYPE IF EXISTS typ_predplatne;
DROP TYPE IF EXISTS nazov_zanru;



CREATE TABLE Umelec
(
    id_umelca    SERIAL PRIMARY KEY,
    meno         VARCHAR(256) NOT NULL,
    pocet_albumov INT DEFAULT 0 CHECK (pocet_albumov >= 0),
    popis        VARCHAR(256)
);


CREATE TYPE typ_predplatne AS ENUM ('Basic', 'Premium', 'Family', 'Student', 'Duo');


CREATE TABLE Predplatne
(
    id_predplatne    SERIAL PRIMARY KEY,
    typ              typ_predplatne NOT NULL,
    trvanie          INT            NOT NULL CHECK (trvanie > 0),
    cena             DECIMAL(10, 2) GENERATED ALWAYS AS (
        CASE
            WHEN typ = 'Basic' THEN 0.00
            WHEN typ = 'Duo' THEN 11.99
            WHEN typ = 'Premium' THEN 9.99
            WHEN typ = 'Family' THEN 14.99
            WHEN typ = 'Student' THEN 4.99
            ELSE 0.00
            END
        ) STORED,
    max_pouzivatelov INT GENERATED ALWAYS AS (
        CASE
            WHEN typ = 'Basic' THEN 1
            WHEN typ = 'Duo' THEN 2
            WHEN typ = 'Premium' THEN 1
            WHEN typ = 'Family' THEN 5
            WHEN typ = 'Student' THEN 1
            ELSE 1
            END
        ) STORED
);


CREATE TABLE Pouzivatel
(
    id_pouzivatel     SERIAL PRIMARY KEY,
    heslo             VARCHAR(256)        NOT NULL CHECK (LENGTH(heslo) > 7),
    id_predplatne     INT,
    datum_registracie DATE                NOT NULL,
    email             VARCHAR(256) UNIQUE NOT NULL,
    prezyvka          VARCHAR(256)        NOT NULL,
    CONSTRAINT fk_predplatne
        FOREIGN KEY (id_predplatne)
            REFERENCES Predplatne (id_predplatne)
            ON DELETE SET NULL
);


CREATE TYPE nazov_zanru AS ENUM ('Pop', 'Rock', 'Hip-Hop', 'Jazz', 'Electronic',
    'Classical', 'Metal', 'Country', 'Reggae', 'Blues', 'Folk', 'R&B',
    'Dance', 'Indie', 'Punk', 'Latino', 'K-Pop');


CREATE TABLE Zaner
(
    id_zanru SERIAL PRIMARY KEY,
    Nazov    nazov_zanru NOT NULL UNIQUE
);


CREATE TABLE Album
(
    id_albumu      SERIAL PRIMARY KEY,
    dlzka_albumu   TIME         NOT NULL,
    nazov          VARCHAR(256) NOT NULL,
    datum_vydania  DATE         NOT NULL,
    id_umelca      INT          NOT NULL,
    pocet_skladieb INT DEFAULT 0 CHECK (pocet_skladieb >= 0),
    CONSTRAINT fk_umelec
        FOREIGN KEY (id_umelca)
            REFERENCES Umelec (id_umelca)
            ON DELETE CASCADE
);


CREATE TABLE Skladba
(
    id_skladby      SERIAL PRIMARY KEY,
    datum_vydania   DATE         NOT NULL,
    nazov           VARCHAR(256) NOT NULL,
    dlzka           TIME         NOT NULL,
    id_umelca       INT          NOT NULL,
    id_albumu       INT,
    id_zanru        INT          NOT NULL,
    
    pocet_pocuvania INT DEFAULT 0 CHECK (pocet_pocuvania >= 0),
    FOREIGN KEY (id_umelca)
        REFERENCES Umelec (id_umelca)
        ON DELETE CASCADE,
    FOREIGN KEY (id_albumu)
        REFERENCES Album (id_albumu)
        ON DELETE CASCADE,
    FOREIGN KEY (id_zanru)
        REFERENCES Zaner (id_zanru)
        ON DELETE CASCADE
);


CREATE TABLE Historia_Pocuvania
(
    id_skladby      INT NOT NULL,
    id_pouzivatela  INT NOT NULL,
    pocet_pocuvania INT DEFAULT 1 CHECK (pocet_pocuvania > 0),
    PRIMARY KEY (id_skladby, id_pouzivatela),
    FOREIGN KEY (id_skladby)
        REFERENCES Skladba (id_skladby)
        ON DELETE CASCADE,
    FOREIGN KEY (id_pouzivatela)
        REFERENCES Pouzivatel (id_pouzivatel)
        ON DELETE CASCADE
);


CREATE TABLE Playlist
(
    id_playlistu     SERIAL PRIMARY KEY,
    nazov            VARCHAR(256) NOT NULL,
    id_pouzivatela   INT          NOT NULL,
    datum_vytvorenia DATE         NOT NULL,
    
    CONSTRAINT fk_pouzivatel
        FOREIGN KEY (id_pouzivatela)
            REFERENCES Pouzivatel (id_pouzivatel)
            ON DELETE CASCADE
);


CREATE TABLE Playlist_Skladba
(
    id_playlistu INT NOT NULL,
    id_skladby   INT NOT NULL,
    PRIMARY KEY (id_skladby, id_playlistu),
    FOREIGN KEY (id_playlistu)
        REFERENCES Playlist (id_playlistu)
        ON DELETE CASCADE,
    FOREIGN KEY (id_skladby)
        REFERENCES Skladba (id_skladby)
        ON DELETE CASCADE
);


 
INSERT INTO Zaner (Nazov)
 VALUES ('Pop'),
        ('Rock'),
        ('Hip-Hop'),
        ('Jazz'),
        ('Electronic'),
        ('Classical'),
        ('Metal'),
        ('Country'),
        ('Reggae'),
        ('Blues'),
        ('Folk'),
        ('R&B'),
        ('Dance'),
        ('Indie'),
        ('Punk'),
        ('Latino'),
        ('K-Pop')
 ON CONFLICT (Nazov) DO NOTHING;



INSERT INTO umelec(meno, pocet_albumov)
VALUES ('Pharaoh', 15),
       ('Platina', 5),
       ('Megadeth', 36),
       ('Chris Travis', 13),
       ('SpaceGhostPurrp', 43),
       ('ROCKET', 7)
;

INSERT INTO predplatne(typ, trvanie)
VALUES ('Premium', 30),
       ('Duo', 30),
       ('Basic', 30),
       ('Family', 30),
       ('Student', 30)
;

INSERT INTO pouzivatel(heslo, id_predplatne, datum_registracie, email, prezyvka)
VALUES ('ilovetuke2010', (SELECT id_predplatne FROM predplatne WHERE typ = 'Premium'), '2020-07-07',
        'sosalover59@gmail.com', 'sosalover59'),
       ('#swag2015', (SELECT id_predplatne FROM predplatne WHERE typ = 'Basic'), '2016-09-17',
        'kavecanyrecords@gmail.com', 'kuza2006'),
       ('zxc123441', (SELECT id_predplatne FROM predplatne WHERE typ = 'Family'), CURRENT_DATE,
        'rudenkoartem@gmail.com',
        'iloveshanson'),
       ('trapchik1997', (SELECT id_predplatne FROM predplatne WHERE typ = 'Premium'), '2022-04-05',
        'tarasikherasimov@gmail.com', 'slovil_tilt07'),
       ('jhony5555', (SELECT id_predplatne FROM predplatne WHERE typ = 'Student'), '2019-06-12',
        'kirilokokchoha@gmail.com', 'KopnulDior')
;


INSERT INTO album(dlzka_albumu, nazov, pocet_skladieb, id_umelca, datum_vydania)
VALUES ('0:43:15', 'DOLOR', 12,
        (SELECT id_umelca FROM Umelec WHERE meno = 'Pharaoh' ORDER BY id_umelca LIMIT 1), '2019-07-01'),
       ('0:49:56', 'Опиаты круг', 19,
        (SELECT id_umelca FROM Umelec WHERE meno = 'Platina' ORDER BY id_umelca LIMIT 1), '2019-05-28'),
       ('0:40:48', 'Rust in Peace', 9,
        (SELECT id_umelca FROM Umelec WHERE meno = 'Megadeth' ORDER BY id_umelca LIMIT 1), '1990-01-29'),
       ('0:21:48', 'Ego Trippin', 10,
        (SELECT id_umelca FROM Umelec WHERE meno = 'ROCKET' ORDER BY id_umelca LIMIT 1), '2021-11-29'),
       ('0:51:43', 'Pizza and Codeine', 17,
        (SELECT id_umelca FROM Umelec WHERE meno = 'Chris Travis' ORDER BY id_umelca LIMIT 1), '2012-05-15'),
       ('0:30:35', 'Nasa Gang', 10,
        (SELECT id_umelca FROM Umelec WHERE meno = 'SpaceGhostPurrp' ORDER BY id_umelca LIMIT 1), '2014-03-20')
;

INSERT INTO skladba(datum_vydania, nazov, dlzka, id_umelca, id_albumu, id_zanru, pocet_pocuvania)
VALUES ('2024-05-07', 'Басок', '00:03:55', (SELECT id_umelca FROM Umelec WHERE meno = 'Platina'),
        (SELECT id_albumu FROM album where nazov = 'Опиаты круг'), (SELECT id_zanru FROM zaner WHERE nazov = 'Hip-Hop'),
        450000),
       ('2012-08-17', 'Stonergang', '00:02:55', (SELECT id_umelca FROM Umelec WHERE meno = 'SpaceGhostPurrp'), (null),
        (SELECT id_zanru FROM zaner WHERE nazov = 'Hip-Hop'),
        26454),
       ('2012-10-21', 'Codeine Vision', '00:03:12', (SELECT id_umelca FROM Umelec WHERE meno = 'Chris Travis'),
        (SELECT id_albumu FROM album where nazov = 'Pizza and Codeine'),
        (SELECT id_zanru FROM zaner WHERE nazov = 'Hip-Hop'),
        2438469),
       ('2006-05-07', 'CSO', '00:02:55', (SELECT id_umelca FROM Umelec WHERE meno = 'ROCKET'),
        (SELECT id_albumu FROM album where nazov = 'Ego Trippin'), (SELECT id_zanru FROM zaner WHERE nazov = 'Hip-Hop'),
        653200),
       ('2006-05-07', 'Symphony of Destruction', '00:03:55', (SELECT id_umelca FROM Umelec WHERE meno = 'Megadeth'),
        (null)
           , (SELECT id_zanru FROM zaner WHERE nazov = 'Metal'),
        366019932)
;


INSERT INTO historia_pocuvania(id_skladby, id_pouzivatela, pocet_pocuvania)
VALUES ((SELECT id_skladby FROM Skladba WHERE nazov = 'Басок' ORDER BY id_skladby LIMIT 1),
        (SELECT id_pouzivatel FROM Pouzivatel WHERE prezyvka = 'sosalover59'),
        10),
       ((SELECT id_skladby FROM Skladba WHERE nazov = 'CSO' ORDER BY id_skladby LIMIT 1),
        (SELECT id_pouzivatel FROM Pouzivatel WHERE prezyvka = 'sosalover59'),
        20),
       ((SELECT id_skladby FROM Skladba WHERE nazov = 'Codeine Vision' ORDER BY id_skladby LIMIT 1),
        (SELECT id_pouzivatel FROM Pouzivatel WHERE prezyvka = 'iloveshanson'),
        2),
       ((SELECT id_skladby FROM Skladba WHERE nazov = 'Stonergang' ORDER BY id_skladby LIMIT 1),
        (SELECT id_pouzivatel FROM Pouzivatel WHERE prezyvka = 'slovil_tilt07'),
        2),
       ((SELECT id_skladby FROM Skladba WHERE nazov = 'Symphony of Destruction' ORDER BY id_skladby LIMIT 1),
        (SELECT id_pouzivatel FROM Pouzivatel WHERE prezyvka = 'kuza2006'),
        2)
;

INSERT INTO playlist(nazov, id_pouzivatela, datum_vytvorenia)
VALUES ('Trapchina', (SELECT id_pouzivatel FROM Pouzivatel WHERE prezyvka = 'sosalover59'), CURRENT_DATE),
       ('Cloud Rap', (SELECT id_pouzivatel FROM Pouzivatel WHERE prezyvka = 'sosalover59'), CURRENT_DATE),
       ('Shanson', (SELECT id_pouzivatel FROM Pouzivatel WHERE prezyvka = 'iloveshanson'), CURRENT_DATE),
       ('Ego Mindset', (SELECT id_pouzivatel FROM Pouzivatel WHERE prezyvka = 'KopnulDior'), CURRENT_DATE),
       ('mode:VanyaKohan', (SELECT id_pouzivatel FROM Pouzivatel WHERE prezyvka = 'slovil_tilt07'), CURRENT_DATE)
;

INSERT INTO playlist_skladba(id_playlistu, id_skladby)
VALUES ((SELECT id_playlistu FROM playlist WHERE nazov = 'Trapchina'),
        (SELECT id_skladby FROM Skladba WHERE nazov = 'Басок')),
       ((SELECT id_playlistu FROM playlist WHERE nazov = 'Trapchina'),
        (SELECT id_skladby FROM Skladba WHERE nazov = 'Codeine Vision')),
       ((SELECT id_playlistu FROM playlist WHERE nazov = 'Trapchina'),
        (SELECT id_skladby FROM Skladba WHERE nazov = 'Stonergang')),
       ((SELECT id_playlistu FROM playlist WHERE nazov = 'Trapchina'),
        (SELECT id_skladby FROM Skladba WHERE nazov = 'CSO')),
       ((SELECT id_playlistu FROM playlist WHERE nazov = 'mode:VanyaKohan'),
        (SELECT id_skladby FROM Skladba WHERE nazov = 'Symphony of Destruction'))
;


 
CREATE VIEW Playlist_View AS
SELECT p.id_playlistu,
       p.nazov,
       COUNT(ps.id_skladby) AS pocet_skladieb
FROM Playlist p
         LEFT JOIN Playlist_Skladba ps ON p.id_playlistu = ps.id_playlistu
GROUP BY p.id_playlistu, p.nazov;


 
CREATE VIEW Premium_Users AS
SELECT p.id_pouzivatel,
       p.prezyvka,
       pr.typ AS predplatne_typ
FROM Pouzivatel p
         JOIN Predplatne pr ON p.id_predplatne = pr.id_predplatne
WHERE pr.typ IN ('Premium', 'Duo', 'Family', 'Student');


 
CREATE VIEW Total_Listen_Time AS
SELECT p.id_pouzivatel,
       p.prezyvka,
       SUM(EXTRACT(EPOCH FROM s.dlzka) * h.pocet_pocuvania) / 3600 AS total_listen_time_hours
FROM Historia_Pocuvania h
         JOIN
     Skladba s ON h.id_skladby = s.id_skladby
         JOIN
     Pouzivatel p ON h.id_pouzivatela = p.id_pouzivatel
GROUP BY p.id_pouzivatel, p.prezyvka;


 
CREATE VIEW top_song AS
SELECT s.id_skladby,
       s.nazov,
       s.pocet_pocuvania
FROM Skladba s
ORDER BY s.pocet_pocuvania DESC
LIMIT 10;

 
CREATE VIEW Skladby_Info AS
SELECT id_skladby,
       nazov,
       datum_vydania,
       dlzka,
       id_zanru,
       pocet_pocuvania,
       CASE
           WHEN pocet_pocuvania > 1000000 THEN 'Hit'
           WHEN pocet_pocuvania BETWEEN 100000 AND 1000000 THEN 'Populárna'
           ELSE 'Málo známa'
           END AS popularita
FROM Skladba;


CREATE VIEW Most_Frequent_Genre AS
SELECT
    p.id_pouzivatel,
    p.prezyvka,
    z.Nazov AS najcastejsi_zanr
FROM
    Pouzivatel p
        LEFT JOIN Historia_Pocuvania h ON p.id_pouzivatel = h.id_pouzivatela
        LEFT JOIN Skladba s ON h.id_skladby = s.id_skladby
        LEFT JOIN Zaner z ON s.id_zanru = z.id_zanru
GROUP BY
    p.id_pouzivatel, p.prezyvka, z.Nazov
ORDER BY
    p.id_pouzivatel;


CREATE VIEW Favorite_Artist AS
SELECT p.id_pouzivatel, p.prezyvka, u.meno AS favorite_artist, SUM(h.pocet_pocuvania) AS total_listens
FROM Pouzivatel p
         JOIN Historia_Pocuvania h ON p.id_pouzivatel = h.id_pouzivatela
         JOIN Skladba s ON h.id_skladby = s.id_skladby
         JOIN Umelec u ON s.id_umelca = u.id_umelca
GROUP BY p.id_pouzivatel, p.prezyvka, u.meno
ORDER BY p.id_pouzivatel, total_listens DESC;

CREATE VIEW Hip_Hop_Metal_Songs AS
SELECT
    s.id_skladby,
    s.nazov AS nazov_skladby,
    u.meno AS umelec,
    'Hip-Hop' AS zaner,
    s.dlzka,
    s.pocet_pocuvania,
    COALESCE(a.nazov, 'Без альбому') AS album,
    CASE
        WHEN s.pocet_pocuvania > 1000000 THEN 'Hit'
        WHEN s.pocet_pocuvania BETWEEN 100000 AND 1000000 THEN 'Populárna'
        ELSE 'Málo známa'
        END AS popularita
FROM
    Skladba s
        JOIN
    Umelec u ON s.id_umelca = u.id_umelca
        LEFT JOIN
    Album a ON s.id_albumu = a.id_albumu
        JOIN
    Zaner z ON s.id_zanru = z.id_zanru
WHERE
    z.Nazov = 'Hip-Hop'

UNION

SELECT
    s.id_skladby,
    s.nazov AS nazov_skladby,
    u.meno AS umelec,
    'Metal' AS zaner,
    s.dlzka,
    s.pocet_pocuvania,
    COALESCE(a.nazov, 'Без альбому') AS album,
    CASE
        WHEN s.pocet_pocuvania > 1000000 THEN 'Hit'
        WHEN s.pocet_pocuvania BETWEEN 100000 AND 1000000 THEN 'Populárna'
        ELSE 'Málo známa'
        END AS popularita
FROM
    Skladba s
        JOIN
    Umelec u ON s.id_umelca = u.id_umelca
        LEFT JOIN
    Album a ON s.id_albumu = a.id_albumu
        JOIN
    Zaner z ON s.id_zanru = z.id_zanru
WHERE
    z.Nazov = 'Metal'

ORDER BY
    zaner, pocet_pocuvania DESC;

CREATE VIEW Popular_Artists_View AS
SELECT
    u.id_umelca,
    u.meno AS meno_umelca,
    u.pocet_albumov,
    s.nazov AS nazov_skladby,
    s.pocet_pocuvania
FROM
    Umelec u
        JOIN
    Skladba s ON u.id_umelca = s.id_umelca
WHERE
    s.pocet_pocuvania > (
        SELECT AVG(pocet_pocuvania)
        FROM Skladba
    )
ORDER BY
    s.pocet_pocuvania DESC;

CREATE VIEW Active_Listeners_View AS
SELECT
    p.id_pouzivatel,
    p.prezyvka,
    p.email,
    pr.typ AS predplatne_typ,
    (
        SELECT COUNT(DISTINCT h.id_skladby)
        FROM Historia_Pocuvania h
        WHERE h.id_pouzivatela = p.id_pouzivatel
    ) AS unique_tracks_listened,
    (
        SELECT SUM(h.pocet_pocuvania)
        FROM Historia_Pocuvania h
        WHERE h.id_pouzivatela = p.id_pouzivatel
    ) AS total_plays,
    (
        SELECT u.meno
        FROM Umelec u
                 JOIN Skladba s ON u.id_umelca = s.id_umelca
                 JOIN Historia_Pocuvania h ON s.id_skladby = h.id_skladby
        WHERE h.id_pouzivatela = p.id_pouzivatel
        GROUP BY u.meno
        ORDER BY SUM(h.pocet_pocuvania) DESC
        LIMIT 1
    ) AS favourite_artist
FROM
    Pouzivatel p
        LEFT JOIN
    Predplatne pr ON p.id_predplatne = pr.id_predplatne
ORDER BY
    total_plays DESC NULLS LAST;



CREATE OR REPLACE PROCEDURE pridaj_noveho_umelca(
    p_meno VARCHAR,
    p_pocet_albumov INT,
    p_popis VARCHAR DEFAULT NULL
)
    LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO Umelec (meno, pocet_albumov, popis)
    VALUES (p_meno, p_pocet_albumov, p_popis);

    RAISE NOTICE 'Nový umelec "%" bol úspešne pridaný do databázy', p_meno;
END;
$$;

CREATE OR REPLACE FUNCTION get_song_count_in_playlist(
    p_playlist_id INT
)
    RETURNS INT
    LANGUAGE plpgsql
AS $$
DECLARE
    song_count INT;
BEGIN
    SELECT COUNT(*) INTO song_count
    FROM Playlist_Skladba
    WHERE id_playlistu = p_playlist_id;

    RETURN song_count;
END;
$$;



CALL pridaj_noveho_umelca('Lil Pump', 10);
SELECT get_song_count_in_playlist(1);


COMMIT;
