SELECT * 
FROM mlbanalysis.mlbyoutubestats;

-- created proxy measures of popularity by calculating views/video(overall popularity) and views/subscriber(popularity amongst fanbase)
SELECT team, round(viewCount/videoCount,2)as views_per_video,
		round(viewCount/subscriberCount,2) as views_per_subsriber
FROM mlbanalysis.mlbyoutubestats
order by views_per_video desc;

-- ranked teams based on total subscribers, total views and total videos
SELECT team,subscriberCount, rank() over(order by subscriberCount desc) as subscriber_rank,
		rank() over (order by viewCount desc) as views_rank, rank() over (order by videoCount desc) as video_rank
from mlbanalysis.mlbyoutubestats
order by subscriber_rank;

-- assigned teams a following classification based on their subscriber rank
select team, 
		CASE
        WHEN subscriber_rank <= 10 THEN 'Strong Following'
        WHEN subscriber_rank <= 20 THEN 'Mediocre Following'
        ELSE 'Poor Following'
        END as following_strength
from(SELECT team,subscriberCount, rank() over(order by subscriberCount desc) as subscriber_rank,
		rank() over (order by viewCount desc) as views_rank, rank() over (order by videoCount desc) as video_rank
	from mlbanalysis.mlbyoutubestats
    order by team asc) as rnk_tbl
    
-- joined the YouTube stats table with a league table to aggregate subscribers, video count, and views grouped by league    
with cte as (select stats.team as team,league, viewCount,subscriberCount,videoCount
	from mlbanalysis.mlbyoutubestats as stats
	left join mlbanalysis.leagues as lgs
	on stats.team = lgs.team)
    
select league,sum(subscriberCount) as total_subscribers,
		sum(videoCount)as total_videos ,sum(viewCount) as total_views
from cte
group by league
    
        