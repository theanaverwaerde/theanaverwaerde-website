---
layout: default
title: Blog
permalink: /blog
---

<!-- On this page you can see all my latest posts -->

# Blog

{% for post in site.posts %}

## [{{ post.title }}]({{ post.redirect_to | default: post.url }})

{{ post.excerpt }}

[Read more]({{ post.redirect_to | default: post.url }})
{% endfor %}
