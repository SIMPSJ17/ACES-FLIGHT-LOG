VERSION 2.0 BUILD 1
8 AUG 2024

      -Added edit capabilities to the logbook view had to make sure the information was being passed to the edit view first ended up being the problem had to start over after running into muiltiple problems and make sure I build it in the order I want the data to be passed and processed.
      
      -corrected the semi period functions had issues where p2nhrs and a couple others had the wrong date need to be careful when using copy paste
      
      -added an image to the total screen of the aircraft the user has selected. 
      
      -Created update function it makes sure all the logs in firestore have a comments field and if it doesn't sets it to "" then it itereates over every log and if the aircraft isnt set to sim or ah64 then it makes the seat blank
      
      -Added function to logflight and edit flight log save buttons to ensure that the seat is logged as "" if the required perameters to display  it are not met
      
      -adjusted the logbookitemview to display seat when it equals front or back to make sure sim logs with a seat position the seat is displayed.
      
      -Removed albutton & headerview as they are no longer needed.



VERSION 1.7 BUILD 1
7 AUG 2024

      -Updated login function to handle error’s in the error = error

      -Corrected p1thrs, p2thrs, p2nhrs calculations

      -Added comments capability and implemented function to add the field to all the flightlogs if DB version for the user isn’t correct

VERSION 1.5 BUILD 1
31 JULY 2024

      -Made a Pickerlistmodel to create a central list pull from to make additions 	simpler in the future

      -Updated Settings Page View Interface had to create a custom hour picker view and use navigation link because I wanted to use a wheel picker

      -Updated Date calculations to us the users current timezone to fix issues with date calculations

      -Added Function to check for UserDefault values in SettingsManager and then set values if there aren’t any values present

      -Updated Forgot Password, login, and register views since I separated the view into different structs I had to use @observedObject instead of $StateObject because the different structures where reinitializing the view when they where changes. 

      -Fixed Background issues with log flight view causing aircraft that are not AH-64’s to still log seat position inserted if func when the button is pressed on logflightview to check the aircraft and if SIM is selected and AH-64 is set as the aircraft in settings manager before setting the seatposition = “”

      -Updated StartPage view and renamed it card view set a tabview for the cards with a page format and turned the index to always on so the user can see what page they are on
      
VERSION 1.4 BUILD 1
7 JUNE 2024

NOTES

      -TOTAL HOURS NOT USING THE ALLOWEDAIRCRAFT() TO FILTER OUT THE SIMULATOR TIMES
      
      -FIXED ISSUES WHERE IF THE BIRTHDAY < TODAY IT WOULD CYCLE TO NEXT SEMIANNUAL PERIOD
      
      -FIXED ISSUE WHERE IF SETTINGSMANAGER.SHARED.AIRCRAFT = "AH-64" SEAT POSITION WOULDNT SHOW UP WHEN SIM WAS SELECTED ON LOG FLIGHT PAGE


VERSION1.3  BUILD 1
6 JUNE 2024


      -ADDED IOS 15.5 SUPPORT FOR IPAD MINI 4 USERS

      -DIFFICULT CANT USE NAVIGATIONVIEWS OR NAVIGATIONSTACK
      



      -DELETED DELETE ACCOUNT ALERT
IMPORVED DELETE ACCOUNT FUNCTION

      -CREATED DELETEACCOUNTVIEW AND VIEWMODEL IN ORDER TO REAUTHENTICATE AS REQUIRED BY FIREBASE TO DELETE ACCOUNT
      
      -SIMPLIFIED THE DELETE FUNCTION AND REMOVED THE LOGOUT IN THE DELETE FUNCTION BECAUSE IT WASN'T NEEDED
      
      -IMPLEMENTED DELETE USER DATA EXTENSION THAT LISTENS FOR FIRBASEAUTH USER ACCOUNT DELETIONS AND THEN DELETES THIER DATA


