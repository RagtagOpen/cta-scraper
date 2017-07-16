# CTA Scraper

This webapp performed scheduled webscraping of politically-oriented calls to 
action (CTAs). It has 2 main components
1. Scrape sites and send the results to the  CTAAggregator API.
2. Admin Panel to display unsucessful scraping attempts (alerting admins that the sraper scripts need to be updated)



ToDo
update Readme
center devise pages
Style homepage


# Admins
There is a rake task for creating an admin. You'll need to pass
```
rake admin:create['sam@aol.com','password123']
```
This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
