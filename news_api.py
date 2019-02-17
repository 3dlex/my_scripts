#!/usr/bin/env python3
#Description: Simple script to pull current headlines
#Requires:
# requests
#
#Author: Matthew Davidson
#Date: 02-17-2019

# Imports
import requests

def NewsFromABC():
    
    # ABC news api base link
    base_url = "https://newsapi.org/v2/top-headlines?sources=abc-news&apiKey="
    # insert your api key https://newsapi.org/register
    api_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    #Combine base url and api key to form news url
    main_url = ''.join([base_url, api_key])
    
    # fetching data in json format
    open_abc_page = requests.get(main_url).json()
    
    # getting all articles in a string article
    article = open_abc_page["articles"]
    
    # empty list which will 
    # contain all trending news and links
    results = []
    links = []
    
    # Fetching artiles and links
    for ar in article:
        results.append(ar["title"])
    
    for li in article:
        links.append(li["url"])
 
    for i in range(len(results)):
        
        # printing all trending news
        print(i + 1, results[i], "\n", links[i])
        
# Driver Code
if __name__ == '__main__':
    
    # function call
    NewsFromABC()
