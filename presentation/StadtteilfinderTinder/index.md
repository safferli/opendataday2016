---
title       : Frankfurt Stadtteilfinder Tinder
subtitle    : 
author      : Christoph Safferling
url         : {lib: "."}    # this is important for reveal.js
framework   : revealjs      # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
--- ds:frankfurt

<!-- title slide -->

<p style="color: #13DAEC; font-family: 'Lato', sans-serif; font-size: 180%; margin: 0 0 25% 0;">
  Frankfurt Stadtteilfinder Tinder <br />
  <span style="font-size: 80%;"></span>
</p>

<p style="font-size: 130%; color: #ffffff;">
  Hackfrankfurt <br/ >
  Open Data Day 2016
</p>


<style>
.gif150
{
  width: 150%;
  height: auto;
}
</style>

<style>
html.frankfurt body {
background:url("./assets/img/frankfurt.jpg");
background-position:center;
background-size: 100%;
background-repeat: no-repeat;
background-color: #35383b;
} 
</style>
<!-- image credit: https://www.flickr.com/photos/friedrichs/14260935259/ -->

--- 

## Frankfurt

- 16 area districts (*Ortsbezirke*)
- 46 city districts (*Stadtteile*)
- 118 city boroughs (*Stadtbezirke*)
  
<!-- -->
  
   
&hellip; where would you want to live? 


---

## Setup

- randomly pick a Frankfurt address
    - from [Hauskoordinaten open data](http://offenedaten.frankfurt.de/dataset/hauskoordinaten-franfurt)
- present the user with a photo of the address
    - from the [Google Streetview API](https://developers.google.com/maps/documentation/streetview/)
- user "swipes" left ("don't like"), or right ("like")
    - store all swipes on the server
    - present the "*district match*", and a heatmap of "*district love*"


--- &vertical

## The App in Action!

http://ec2-52-11-118-34.us-west-2.compute.amazonaws.com:3000/

***

## Stadtteilfindertinder

<img src="assets/img/frankfurtsscreenshot.png" />

***

## Rankfurt

<img src="assets/img/sample_map_small.png" />


---

## Technology used

- [node.js](https://nodejs.org/en/) for the server
- [socket.io](http://socket.io/) for server/client communication
- [amazon aws](https://aws.amazon.com/) for the actual VM (free version)
- [postgreSQL](http://www.postgresql.org/) for database storing
- [R](https://www.r-project.org/) for calculations and mapping
- [plumbeR](https://github.com/trestletech/plumber) for RESTful communication between R and node.js
- [Ebbelwoi](https://en.wikipedia.org/wiki/Apfelwein) for the idea


---

## Code is on github

https://github.com/safferli/opendataday2016 


--- &vertical

## main obstacles faced

- streetnames and numbers very patchy
- bulk-geolocationing was not possible
- no pretty front-end stuff &#9785;

***

<img src="assets/img/daffy-klatsch.gif" />


---

## Happy Stadtteilfindertindering!

<img src="assets/img/tinder-schnitzel.gif" class="gif150" />
