# foodsta
a social networking app for foodies

Original App Design Project - README Template
===

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
A social networking platform for foodie inspiration! Allows users to check in and share where/what they're eating (location, picture, caption, rating). Leverages Yelp API for location searching and browsing. Also integrates Apple maps with check-in location pins and post pop-ups. Users can search for other foodies and interact with them by liking their check-in posts, following them, and browsing their profile pages.

### App Evaluation
[Evaluation of your app across the following attributes]

- **Category:** Social Networking / Food
- **Mobile:** This app would be geared towards mobile because users would be primarily posting outside/at various food places. The phone camera also allows for easy posting of pictures. A desktop version would be possible although more limited (i.e. Instagram feed browsing on desktop). 
- **Story:** Provides inspiration for foodies, using double feed and map visualization views to browse recent check-ins made by users on the platform.
- **Market:** Any individual could use this app. Most likely popular among people age 15-40.
- **Habit:** Depends on the user. Some may be just browsing for inspiration on where to eat, others may be posting very often and creating a foodie profile.
- **Scope:** First, we would start with allowing users to post, like, and follow. Potentially, we can evolve this by adding more of the networking aspect, i.e. pairing or suggesting users based on food preferences. 



## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Users can log in/log out
* Users can create a new account
* Users can view a feed of check-in posts
* Users can like/double tap to like a check-in post
* Users can post a check-in (with camera functionality)
* Users can search for/follow other users
* Users can view profile pages of other users
* Users can edit their profile (picture and bio)

**Optional Nice-to-have Stories**

* Users can view a map visualization of locations where friends have checked in recently
* Users can toggle between map visualizations and post feeds of check-in posts on profile pages
* Users can view/clear their recent search history

### 2. Screen Archetypes

* Login Screen - User signs up or logs into their account
   * Upon downloading/reopening of the application, the user is prompted to log in to gain access to their feed
 
* Home Feed Screen - table view of recent check-ins made by anyone the user is following
   * Automatically loads upon logging in

* Compose Screen - user posts a check-in with required location and rating and optional photo and caption
   * Allows user to upload a photo, check in to a location, add a rating, and write a caption (i.e. review of the restaurant)

* Profile Screen - contains user information
   * View any user's username, profile picture, bio, and check-ins (table view and possibly a map too).

* Search Screen - search for other users on the platform
   * Searches entire database for a user and links to their profile page

* Map Screen - visualization of pinned check-in locations with post pop-ups
   * Centers on current user location


### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home feed
* Search page
* Compose page (to post a check-in)
* Profile page
* Optional: map
* Optional: settings

**Flow Navigation** (Screen to Screen)

* Login Screen - User signs up or logs into their account
   * Home Feed
   * Alert message pop-ups if sign-up or login fails
 
* Home Feed Screen
   * Profile Page (by clicking the username on a check-in post)
   * Yelp webpage (by clicking check-in location on a post)
   * Compose Screen (upon clicking compose button)
   * Login Screen (upon clicking log out button)

* Search Bar Screen
    * Profile page (by clicking a search result)

* Compose Screen - user posts a check-in with required location and rating, optional photo and caption
   * Yelp Search Screen (upon clicking location search bar)
   * Pop-up menu with photo library or camera (upon clicking the add image button)
   * Home Feed Screen (with new check-in at the top upon successfully posting)
 
* Profile Screen - contains user information
   * Followers/Following lists (table views of user cells that link to profile pages)
   * Edit Profile Screen (can update profie picture and bio)
   * Login Screen (upon clicking log out button)
   * Optional: toggle between map visualization of check-in locations and post feed

## Wireframes
![](https://i.imgur.com/gxnNpC7.jpg)
