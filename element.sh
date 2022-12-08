#! /bin/bash
#Script to accept atomic_number, symbol or name of and element and output information about the given element

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

if [[ $1 ]]
then
  #if argument is not a number
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
    #check length of argument
    if [[ ${#1} > 2 ]]
    then
      #if more than 2 get element info using name
      ELEMENT_INFO=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE name='$1'")
      
    else
      #get element info using symbol
      ELEMENT_INFO=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol='$1'")
      
    fi
  else
    #get the element info
    ELEMENT_INFO=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number=$1")
    
  fi

  #if element does not exist
  if [[ -z $ELEMENT_INFO ]]
  then
    echo I could not find that element in the database.
  else

    IFS="|"   
    read ATOMIC_NUMBER SYMBOL NAME <<< $ELEMENT_INFO
    unset IFS
    
    #get the properties info for the element
    PROPERTIES_INFO=$($PSQL "SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
    
    IFS="|"   
    read TYPE ATOMIC_MASS MELTING_PT_CEL BOILING_PT_CEL <<< $PROPERTIES_INFO
    
    unset IFS
    
    #output the information about the element
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_PT_CEL celsius and a boiling point of $BOILING_PT_CEL celsius."
  fi

else
  echo Please provide an element as an argument.
fi
