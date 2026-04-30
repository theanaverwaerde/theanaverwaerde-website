---
layout: default
title: Home
permalink: /
---

<!-- On this page I put what I want to highlight -->

# Hey, I'm **Théana**

I am a software and game developer based in France.

## My latest project

It's a walking sim game made in 72h during the LD59 with a friend

[Play on your browser here<br><br><img src="https://static.jam.host/content/cfb/71/z/71818.png.948x533.fit.jpg" alt="Cover image of the game" width="400" loading="lazy">](https://ldjam.com/events/ludum-dare/59/lowsignal)


## Latest Posts

<ul>
    {% for post in site.posts limit:5 %}
        <li>
            <a href="{{ post.url }}">{{ post.title }}</a>
            <small>{{ post.date | date: "%B %d, %Y" }}</small>
        </li>
    {% endfor %}
</ul>
