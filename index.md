---
layout: default
title: Home
permalink: /
---

<!-- On this page I put what I want to highlight -->

# Hey, I'm **Théana**

I am a software and game developer based in France.

## Latest Posts

<ul>
    {% for post in site.posts limit:5 %}
        <li>
            <a href="{{ post.url }}">{{ post.title }}</a>
            <small>{{ post.date | date: "%B %d, %Y" }}</small>
        </li>
    {% endfor %}
</ul>