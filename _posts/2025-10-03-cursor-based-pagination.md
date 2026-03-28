---
discussion_id: 2
layout: post
summary: Learn why and how to make a pagination cursor-based for your APIs
title: Why and how to make a pagination cursor-based?
---

## Why use pagination?

When you read a book you don't want to have all the text in only one page, we split the content into many pages to easily browse and read information.

For an API it's similar, we prefer to send data page by page for performance issues because reading all the database at every call is heavy instruction, and if the user just needs top 5, we don't want to send useless data.

## Why do pagination with cursor?

For pagination, the most common option is with offset and limit, but if you need performance or consistency, check out what the cursor based pagination can do below. However, if you need direct navigation to a certain page cursor based pagination is more heavy compare to offset, the main strength is page per page!
### Performance

Database is better to do filter instead of skip, the difference is small at start but if you have a huge dataset the impact can be huge.

In my own machine with PostgreSQL database, I do [a script available in GitHub Gist](https://gist.github.com/theanaverwaerde/fc9385edcc85499ab5a67dfc1888a160) to benchmark timing between pagination by offset vs cursor.

| Page | Offset (ms) | Cursor (ms) |
| ---: | :---------- | :---------- |
|    1 | 0.406       | 0.386       |
|   10 | 0.744       | 0.360       |
|  100 | 4.047       | 0.366       |
|  500 | 18.635      | 0.359       |
| 1000 | 36.580      | 0.364       |

With Cursor-based pagination time is constant (**O(1)**) per page. With Offset-based pagination time increases linearly (**O(n)**), get the latest page is much longer compare to first.

### Consistency

If your data can change in real time, when you want your latest 

{% picture
cursor-based-pagination/light.png
dark: cursor-based-pagination/dark.png
--alt Visual comparison of offset and cursor pagination, illustrating how offset pagination can skip or repeat items if new data is added, while cursor pagination maintains correct order.
%}

## Required

An indexed column like a sortable id or datetime but need to be unique to avoid duplicate values

About Sortable ID you have auto increment number or time-based format
- ULID[^ulid]
- UUID v6 or v7
- ObjectId (MongoDb)[^objectid]

[^ulid]: Universally Unique Lexicographically Sortable Identifier knows as **ULID** has 128 bits length including 48 bits of Unix timestamp in milliseconds.
    Format looks like `01ARZ3NDEKTSV4RRFFQ69G5FAV`.
    You can find [full spec on github](https://github.com/ulid/spec).

[^objectid]: The default ID in MongoDb is called **ObjectId** composed of 96 bits length including 32 bits of Unix timestamp in seconds.
    Format looks like `507f1f77bcf86cd799439011`.
    Full information in [MongoDB documentation](https://www.mongodb.com/docs/manual/reference/bson-types/#std-label-objectid)

### Wait, UUID isn't fully random??

No, since UUID v6, 48 bits are allocated for Unix timestamp in milliseconds. If you want to read more information about UUID evolution, you can visit [this site](https://uuidgenerator.ai/v7) to know the structure of different UUID versions

## Implementation

This is an exemple with an id encoded in base64

- Call for the first page (without any cursor)
    - Request your data with a limit
    - Get the last ID of your request
    - Encode it to base64
    - Send it with data of your first page

    `GET https://www.theanaverwaerde.dev/api/data`

    ```json
{
    "data": [{},{}],
    "next_cursor": "OTk5"
}
    ```

- Next calls when cursor is specified
    - Decode your base64 cursor as your `last_id`
    - Request your data with a filter `WHERE id > last_id` and a limit
    - Get the last ID of your request
    - Send it with data of your page

    `GET https://www.theanaverwaerde.dev/api/data?cursor=OTk5`

    ```json
{
    "data": [{},{}],
    "next_cursor": null
}
    ```

***Reminder:** Use Parameterized Queries in SQL for the last_id to avoid injection-based attacks!*

---