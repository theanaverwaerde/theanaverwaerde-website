---
layout: post
summary: How to upload file on Playfab Economy v2 via API
title: Upload a file for Item in PlayFab Catalog V2
discussion_id: 3
---
The official documentation doesn't explain in detail how to upload a file for an Item in PlayFab Catalog V2, so after some research here's the method I found

I use [C# PlayFab SDK ](https://www.nuget.org/packages/PlayFabAllSDK/) as example in this article but all rest api documentation of each call are here

1. [Connection to Playfab](#connection-to-playfab)
2. [Request for Upload Urls](#request-for-upload-urls)
3. [Put your file with Azure Endpoints](#put-your-file-with-azure-endpoints)
4. [Link file on the Item](#link-file-on-the-item)

## Connection to Playfab

You need to have a entity token, with your Title Id and your Secret Key
If you not yet have your secret key you can get it on your Dashboard -> Settings -> Secret Keys and you can generate a new one.
```csharp
PlayFabSettings.staticSettings.TitleId = Environment.GetEnvironmentVariable("TitleId");
PlayFabSettings.staticSettings.DeveloperSecretKey = Environment.GetEnvironmentVariable("SecretKey");
await PlayFabAuthenticationAPI.GetEntityTokenAsync(new GetEntityTokenRequest());
```

## Request for Upload Urls

The first step to add a file is to requesting a upload url to PlayFab, so call [CreateUploadUrls](https://learn.microsoft.com/en-us/rest/api/playfab/economy/catalog/create-upload-urls)
On the body, you can request many urls in one time Files field is a List\<UploadInfo\>
```csharp
PlayFabResult<CreateUploadUrlsResponse>? urls = await PlayFabEconomyAPI.CreateUploadUrlsAsync(new CreateUploadUrlsRequest()
{
    Files = [
        new UploadInfo
        {
            FileName = "example.txt"
        }
    ]
});
```
## Put your file with Azure Endpoints
According to [PlayFab official documentation for CreateUploadUrlsRequest](https://learn.microsoft.com/en-us/rest/api/playfab/economy/catalog/create-upload-urls#createuploadurlsrequest) now you need must follow the [Microsoft Azure Storage Blob Service REST API](https://learn.microsoft.com/en-us/rest/api/storageservices/put-blob) pattern for uploading content 
In C# we need a HttpClient to put do this call cause C# PlayFab SDK doesn't provide it.

For your Put you need a header `x-ms-blob-type` value can be BlockBlob, PageBlob or AppendBlob. You can check what you need on [doc](https://learn.microsoft.com/en-us/rest/api/storageservices/understanding-block-blobs--append-blobs--and-page-blobs)
```csharp
HttpClient httpClient = new HttpClient();

foreach (UploadUrlMetadata url in urls.Result.UploadUrls)
{
    byte[] fileBytes = await File.ReadAllBytesAsync(file.FullName);
    ByteArrayContent content = new ByteArrayContent(fileBytes)
    {
        Headers = { { "x-ms-blob-type", "BlockBlob" } }
    };
    
    HttpResponseMessage res = await httpClient.PutAsync(url.Url, content);
    // Throws an exception if the IsSuccessStatusCode property for the HTTP response is false.
    res.EnsureSuccessStatusCode();
}
```

## Link file on the Item

Finally you can use Ids and Urls from the response of [Create Upload Urls](#create-upload-urls) in for create or update an item

```csharp
PlayFabResult<CreateDraftItemResponse>? draftItem = await PlayFabEconomyAPI.CreateDraftItemAsync(new CreateDraftItemRequest()
{
    Item = new CatalogItem
    {
        ...,
        Contents =
        [
            new Content
            {
                Id = url.Id,
                Url = url.Url
            }
        ]
    }
});
```

And you're done!