# CTA Scraper

This webapp performed scheduled webscraping of politically-oriented calls to 
action (CTAs). It has 2 main components
1. Scrape sites and send the results to the  CTAAggregator API.
2. Admin Panel to display unsucessful scraping attempts (alerting admins that the sraper scripts need to be updated)


# Admins

There is a rake task for creating an admin. You'll need to pass an email and a password as arguments.
```
rake admin:create['sam@aol.com','password123']
```
This process will work well enough when running the app locally.  If you want creds on staging or production,
then have an existing admin run this rake task on your behalf.  This will set you in the system, then
you can reset your password something that no one else knows.

## Testing

This project leverages Rspec for unit and integration tests.

## Local Development

1. This app uses PostrgreSQL, so be sure to have that installed and running on your machine.
2. Clone this repo.
3. CD in the root directory and run `bin/setup`.  This command should create your database and install any dependencies

## Deployment
This app is deployed on Heroku.  There's a staging site and a production site.
