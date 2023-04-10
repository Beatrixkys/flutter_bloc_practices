# flutter_counter

This flutter project is to create understanding on the high level of the bloc design. 

# What is the bloc design? 

By adding the BLoC to the presentation layer, this segregates the business logic from the view. Furthermore, without tight binding, the BLoC can be used with more than just one view and with widgets. 

# How is it implemented in thsi application?

BlocObserver: To show all the state changes in the application 
Main: create an instance of the Bloc Observer before running the Counter App

Counter Page: Creates a BlocProvider widget with a Cubit stream and a counter view

Counter Cubit: Contains the counter "Events" but simplify the way it emits states: it stores observable state in streams, managing as int as its state 

Counter View: Contains the actual UI of the app, calls the increment to change the state, reads the state to display the counter 