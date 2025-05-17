# Spotify-style Music Streaming Database (PostgreSQL)

This is a university project simulating a relational database for a streaming platform like Spotify. It includes users, artists, songs, playlists, and listening history — with views, functions, and stored procedures.

## Features

- Normalized schema with proper keys and constraints
- ENUM types for genres and subscription types
- Auto-calculated fields (price, user limits)
- User listening history and favorite artists
- Views for analytics and usage tracking
- Stored procedure and function for insertion and stats

## Stack

- PostgreSQL
- SQL (DDL, DML, Views, Functions, Procedures)
- Sample data included

## Getting Started

1. Clone this repository
2. Run `odovzdavka-3.sql` in your PostgreSQL environment
3. Explore the structure and views using pgAdmin or DBeaver

## Example Views

- `Playlist_View`: Count of songs per playlist  
- `Total_Listen_Time`: Total listen time per user  
- `Favorite_Artist`: Most listened-to artist per user  
- `Popular_Artists_View`: Songs above average popularity

## Author

Yurii Chechur  
 
