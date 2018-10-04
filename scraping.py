import time
import random
from requests import get
from bs4 import BeautifulSoup
from IPython.core.display import clear_output
# docs is https://www.dataquest.io/blog/web-scraping-beautifulsoup/

# Redeclaring the lists to store data in
names = []
years = []
imdb_ratings = []
metascores = []
votes = []

# Preparing the monitoring of the loop
start_time = time.time()
reQnum = 0

# For every year in the interval 2000-2017
for year_url in range(2000,2018):

    # For every page in the interval 1-4
    for page in range(1,5):

        # Make a get request
        response = get('http://www.imdb.com/search/title?release_date= + year_url + &sort=num_votes,desc&page= + page')

        # Pause the loop
        time.sleep(random.randint(8,15))

        # Monitor the requests
        reQnum += 1
        elapsed_time = time.time() - start_time
        print('Request:{}; Frequency: {} requests/s'.format(reQnum, reQnum/elapsed_time))
        clear_output(wait = True)

        # Throw a warning for non-200 status codes
        if response.status_code != 200:
            warn('Request: {}; Status code: {}'.format(requests, response.status_code))

        # Break the loop if the number of requests is greater than expected
        if reQnum > 72:
            warn('Number of requests was greater than expected.')
            break

        # Parse the content of the request with BeautifulSoup
        page_html = BeautifulSoup(response.text, 'html.parser')

        # Select all the 50 movie containers from a single page
        mv_containers = page_html.find_all('div', class_ = 'lister-item mode-advanced')

        # For every movie of these 50
        for container in mv_containers:
            # If the movie has a Metascore, then:
            if container.find('div', class_ = 'ratings-metascore') is not None:

                # Scrape the name
                name = container.h3.a.text
                names.append(name)

                # Scrape the year
                year = container.h3.find('span', class_ = 'lister-item-year').text
                years.append(year)

                # Scrape the IMDB rating
                imdb = float(container.strong.text)
                imdb_ratings.append(imdb)

                # Scrape the Metascore
                m_score = container.find('span', class_ = 'metascore').text
                metascores.append(int(m_score))

                # Scrape the number of votes
                vote = container.find('span', attrs = {'name':'nv'})['data-value']
                votes.append(int(vote))
# now you can print the array of names, years,imdb_ratings,metascores  and votes and the values