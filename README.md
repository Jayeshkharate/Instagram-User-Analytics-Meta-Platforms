Instagram User Analytics — Meta Platforms

A SQL data analysis project that mines Instagram user data to help Meta's marketing team build targeted strategies that increase user engagement, retention, and acquisition. The analysis turns raw interaction data (posts, likes, comments, tags, follows) into clear, actionable recommendations.


The Problem

Meta's marketing team wants to grow Instagram — but growth spend is wasted without knowing who to target, what content resonates, and which users are slipping away.

The core question this project answers:


How can Instagram's user data be used to drive higher engagement, retain users, and acquire new ones through targeted marketing?



To answer it, the project uses SQL to interrogate the platform's data and address six specific business objectives:


How user activity is distributed across the user base
The average engagement rate per post for each user
The users with the highest engagement rates (top influencers)
Total engagement over a month
The most popular hashtags
Users who have never engaged (never liked a post)



What I Did

Worked directly with the relational data model — users, photos, comments, likes, tags, and follows — joining across tables to answer each business question.

1. Measured user activity levels


Counted posts, comments, and likes per user to profile the base
Found most users are lightly active, with a small, highly active core


2. Calculated engagement


Defined engagement rate per user as (total likes + comments) / total posts
Ranked users to surface the most engaged accounts


3. Ranked top users & influencers


Identified the top 10 users by engagement rate
Built a monthly engagement leaderboard (likes + comments + tags)


4. Found what content works


Ranked the most-liked hashtags to reveal trending interests
Mapped top influencers to the tags they use, enabling interest-based ad targeting


5. Flagged inactive users


Isolated users with zero likes and zero comments for re-engagement campaigns



Key Findings

InsightWhat it meansMost users have fewer than 10 posts; activity is concentrated in a few usersA small core drives most content — prioritize and reward themHighest engagement rate: Meggie_Doyle (~75)Clear top engager to study and partner withMonthly engagement leader: Eveline95 (418)Best account for time-bound campaign amplificationMost-liked hashtag: #dreamy; top tags include fun, smile, happy, concertContent and ads should ride proven, high-interest tags23% of users are inactive (never liked or commented)A large, recoverable audience for re-engagementInfluencers map cleanly to interest tags (e.g. Janet.Armstrong -> beauty)Enables precise, interest-matched influencer campaigns


Conclusion

A data-driven approach lets Meta's marketing team turn raw Instagram activity into concrete strategy. The analysis shows exactly who to amplify (top engagers and influencers), what content performs (the most-liked hashtags and interest tags), and who to win back (the 23% inactive users).

Recommended actions:


Personalize content by segmenting users on their interests and tag behaviour
Target proven hashtags and align ad content with trending interests
Partner with high-engagement influencers, matched to relevant interest tags
Run re-engagement campaigns (personalized offers, Stories/Reels) for inactive users
Continuously A/B test and monitor performance to refine what works


In short: the queries reveal where engagement lives, what drives it, and where it's leaking — giving the marketing team a measurable foundation to grow engagement, retention, and acquisition.


Tools & Skills

MySQL — Joins, Aggregations, Grouping, Subqueries, Window Functions (ranking), CTEs
Skills — Data Analysis, User Analytics, Engagement & Retention Metrics, Data Visualization, Data Storytelling

Files in This Repository

FileDescriptionSQL SCRIPT BY JAYESH KHARATE.sqlAll SQL queries used to answer the business objectivesSQL QnA BY JAYESH KHARATE.docxWritten breakdown of each question, query, and resultjayesh sql ppt.pptxPresentation walking through the analysis, findings, and strategy


Author: Jayesh Kharate · Data Analyst
