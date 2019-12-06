# Marvel Homework -- Submitted by Randy Weinstein 12/3/19

## Deployment Target: 
iOS 12.0

## XCode Version:
11.2.1

## Dependencies used:
None. I thought the project scope and timeline did not warrant inclusion of dependencies.

I did make extensive use of this API solution: 
https://github.com/victorpimentel/MarvelAPI

I did some modest refactoring on the above solution to flesh out the comicbook view model and vet its injection into a generic class proxying for the view controller. That is all embodied in the Marvel API playground included in this repo along with the homework project. 

## Project Scope:
The homework app fetches a pre-defined comic book data set and displays thumbnail, title, description, and both cover and interior contributors. I referenced the comic book details view in the Marvel app but substantially reivsed the presentation of contributors. I avoided nesting a scrolling view inside a scrolling view. These are tricky to implement successfully. In the production app, I am unable to consistently scroll the embedded scrolling view on my XS Max and was never able to view the bottom few lines where the publishing date was listed. I also was not a fan of the wrapping of the contributor names. My design solution addresses these issues, but I do NOT claim to be a designer

Downloaded comic meta data and thumbnail image are persisted locally -- metadata in user defaults and thumbnail image on the file system. If the app was able to successfully download meta data but failed to fetch the image, the local store will be wiped out on the next session and a remote fetch will be attempted again. 

## Architecture
MVVM using closures to achieve data bindings. I considered using a delagate pattern but decided this was working well enough and I was already behind on submitting this ( sorry ! )

## Testing 
I used the playground extensively to vet the API solution I chose and to help architect the view model and its associations with the class instantiating and making requests on its interface.

There are a couple of unit tests. I may do more later this evening. 

