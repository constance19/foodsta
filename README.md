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
A social platform for foodie inspiration! Allows users to check in and share where/what they're eating (required location, optional picture, optional caption). Users can also interact with other foodies by liking their check-in posts, following them, and browsing their profile pages.

### App Evaluation
[Evaluation of your app across the following attributes]

- **Category:** Social Networking / Food
- **Mobile:** This app would be geared towards mobile because users would be primarily posting outside/at various food places. The phone camera also allows for easy posting of pictures. However, a desktop version would be possible but more limited (i.e. Instagram feed browsing on desktop). 
- **Story:** Provides inspiration for foodies. Possible additional feature: map visualization of recent check-ins made by the accounts followed by the user.
- **Market:** Any individual could use this app. Most likely popular among people age 15-40.
- **Habit:** Depends on the user. Some may be just browsing for inspiration on where to eat, others may be posting very often and creating a foodie profile.
- **Scope:** First, we would start with allowing users to post and follow. Potentially, we can evolve this by adding more of the networking aspect, i.e. pairing users based on food preferences. 



## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Users can log in/log out
* Users can create a new account
* Users can view a feed of check-in posts
* Users can like a check-in post
* Users can post a check-in (with camera functionality)
* Users can search for/follow other users
* Users can view profile pages of other users

**Optional Nice-to-have Stories**

* Users can view a map visualization of where friends have checked in recently
* Caching of previously loaded feed

### 2. Screen Archetypes

* Login Screen - User signs up or logs into their account
   * Upon Download/Reopening of the application, the user is prompted to log in to gain access to their feed
   * ...
* Home Feed Screen - table view of check-ins made in the past 48 hours by anyone the user is following
   * Automatically loads upon logging in

* Detailed Post Screen
    * Allows user to click a check-in on their feed for a detailed view of the location, image, and caption, as well as like the check-in


* Compose Screen - user posts a check-in with optional photo and caption
   * Allows user to upload a photo, check in to a location, and write a caption (i.e. review or rating of the restaurant)
* Profile Screen - contains user information
   * View any user's name, username, profile picture, bio, and check-ins.


### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home feed
* Search bar
* Compose page (post a check-in)
* Profile page
* Optional: map
* Optional: settings

**Flow Navigation** (Screen to Screen)

* Login Screen - User signs up or logs into their account
   * Home Feed
   * Alert message pop-ups if sign up or log in fails
 
* Home Feed Screen
   * Detailed Post Screen (by clicking any check-in post on the feed)
   * Profile Page (by clicking the profile picture of a check-in post's author)

* Search Bar Screen
    * Profile page (by clicking a search result)

* Compose Screen - user posts a check-in with optional photo and caption
   * Home Feed Screen (with new check-in at the top upon successfully posting)
 
* Profile Screen - contains user information
   * Detailed Post Screen (by clicking any check-in the user posted)

## Wireframes
![](https://i.imgur.com/gxnNpC7.jpg)
