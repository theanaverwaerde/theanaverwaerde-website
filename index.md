---
layout: default
title: Home
permalink: /
---

<!-- On this page I put what I want to highlight -->

# Hey, I'm **Théana** 👋

Software & Game developer

## My latest project

For my second Kenney Jam, I've made a game in 50h with a designer,<br />
Game made with [Godot Engine](https://godotengine.org)

<iframe frameborder="0" src="https://itch.io/embed/4794159?bg_color=30305e&amp;fg_color=ffffff&amp;link_color=00d1ff&amp;border_color=585886" width="208" height="167"><a href="https://theanaverwaerde.itch.io/smsmsg2-dx">SMSMSG2 DX by Théana, AmauryH</a></iframe>


## Latest Posts

<ul>
    {% for post in site.posts limit:5 %}
        <li>
            <a href="{{ post.url }}">{{ post.title }}</a>
            <small>{{ post.date | date: "%B %d, %Y" }}</small>
        </li>
    {% endfor %}
</ul>
