-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

select * from spotify;

-- EDA 
select count(*) from spotify;  -- check the number of rows -- 20594

select count(distinct artist) from spotify;  -- 2074

select count (distinct album) from spotify;   -- 11854

select distinct album_type from spotify;   -- album, compilation and single

select max(duration_min) from spotify; -- 77.9343 mins 
select min(duration_min) from spotify; -- 0 mins 

-- if cant have songs with 0 mins, lets find them
select * from spotify
where duration_min = 0;
-- we have two songs, we will delete these. 

delete from spotify
where duration_min = 0;

select min(duration_min) from spotify; -- 0.516416667 mins 

select count(distinct channel) from spotify;   -- 6673

select distinct most_played_on from spotify;  -- Youtube and Spotify 

select avg(loudness) from spotify; -- this is the loudness index, lets see its average = -7.678999417249465

------------------------------------------------------------------------------------------

-- Lets solve some queries on this dataset 

------------------------------------------------------------------------------------------

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.
select * from spotify;
select count(stream) from spotify; -- total 20592

select track, stream from spotify
where stream> 1000000000;

select count(stream) from spotify
where stream> 1000000000;  -- the total count is 385

------------------------------------------------------------------------------------------

-- 2. List all albums along with their respective artists.
select * from spotify;

select distinct(album), artist from spotify
ORDER BY 1; 

select count(distinct(album)) from spotify; -- the total count is 11853

------------------------------------------------------------------------------------------

-- 3. Get the total number of comments for tracks where licensed = TRUE.
select * from spotify;


select distinct(licensed) from spotify; -- check this to make sure if the boolean values are all in the same caps or not

select sum(comments) as total_num_of_comments from spotify
where licensed = 'true';        -- 497015695

------------------------------------------------------------------------------------------

-- 4. Find all tracks that belong to the album type single.
select * from spotify;
select distinct(album_type) from spotify;  -- album, compilation and single

select track, album_type from spotify 
where album_type = 'single';

select count(track) from spotify  -- there are total 4973 tracks that belong to album type single
where album_type = 'single';

------------------------------------------------------------------------------------------

-- 5. Count the total number of tracks by each artist.
select * from spotify;

select count(distinct(artist)) from spotify;


select artist, count(track) as total_number_tracks from spotify
group by artist
order by 1;

------------------------------------------------------------------------------------------

-- 6. Calculate the average danceability of tracks in each album.
select * from spotify;

select album, avg(danceability) as average_danceability from spotify
group by album
order by 2 desc;

------------------------------------------------------------------------------------------

-- 7. Find the top 5 tracks with the highest energy values.
select * from spotify;

select track, max(energy) from spotify
group by track
order by max(energy) DESC
LIMIT 5;

------------------------------------------------------------------------------------------

-- 8. List all tracks along with their views and likes where official_video = TRUE.
select * from spotify;

select distinct(official_video) from spotify;

select track, sum(views) as total_views, sum(likes) as total_likes from spotify
where official_video = true
group by track;

------------------------------------------------------------------------------------------

-- 9. For each album, calculate the total views of all associated tracks.
select * from spotify;

select album, track, sum(views) as total_views from spotify
group by album, track; -- need to groupby first the album and then the track becoz we need total views for highest album and track pair

------------------------------------------------------------------------------------------

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.
select * from spotify;


-- create a subquery t1, 

select * from 
(select track,
		COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as stream_on_youtube,
		COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as stream_on_spotify
from spotify
Group by 1)
as t1
where stream_on_spotify> stream_on_youtube
and 
stream_on_youtube <> 0
 
------------------------------------------------------------------------------------------

-- 11. Find the top 3 most-viewed tracks for each artist using window functions.
select * from spotify;

-- each artist and total views for each track
-- track with highest view for each artists


with ranking_artist
as
(select artist, track,
	   sum(views) as total_view, 
	   DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as rank
	   
	   from spotify
group by 1,2
order by 1,3 desc
)
select * from ranking_artist
where rank<=3;

------------------------------------------------------------------------------------------

-- 12. Write a query to find tracks where the liveness score is above the average.
select * from spotify;

select track, liveness from spotify
where liveness >
	(select avg(liveness) as avg_liveness_score
	 from spotify);

------------------------------------------------------------------------------------------

-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
select * from spotify;


WITH cte
as
(select album,
		max(energy) as highest_energy, 
		min (energy) as lowest_energy
from spotify
group by album)

select album,
		(highest_energy - lowest_energy) as energy_diff
from cte
order by 2 desc;

------------------------------------------------------------------------------------------

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT track, energy, liveness, 
       (energy / NULLIF(liveness, 0)) AS ratio
FROM spotify
where (energy / NULLIF(liveness, 0)) > 1.2

------------------------------------------------------------------------------------------

-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

select track, likes, views,
	sum(likes) over (order by views) as cumm_likes
from spotify;

------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------