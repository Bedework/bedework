# Locations in bedework

These are stored internally as location entities. They are created withthe admin client for public events or as a result of specifying or receiving locations for user clients.

## Searching for public locations

There is a web service endpoint which can be used to search for public locations. It takes a filter expression as a parameter and will return <a limited?> number 

A search takes the form:
```
  <scheme-host-port>/locations/all?[params]
```
  
The params are
  * fexpr=expression
  * ?
  
The expression is a valid filter expression. Of particular interest are the following

  * loc_all=a-string
  * geo?
  * ?
  
For example
```
http://localhost:8080/cal/location/all.gdo?fexpr=loc_all=%27some%27
```
