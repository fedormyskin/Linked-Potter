## This file describes how to retrieve information from the RDF/OWL file containing the knowledge base.
# However, it doesn't work on common computers because the number of entities is too high and requires 
# excessive computational power.

## install redland and rdflib
# if you get a configuration error, trying installing redland from a terminal first and then install the R package. For Unix:
# $ brew install pkg-config
# $ brew install redland
# $ export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:~/usr/local/Cellar/redland/1.0.17_1/lib/pkgconfig # (or your local path, if different)

install.packages("redland")
install.packages("rdflib") # excellent introduction to RDF files and use of the package: https://cran.r-project.org/web/packages/rdflib/vignettes/rdf_intro.html

## use RDF/XML file, i.e. the linked data, ontology, knowledge base, or graph database

library(rdflib)
library(tidyverse)

# download the ontology file from the OSF repository: https://osf.io/azu86

# open and parse the RFD/XML file (.rdf, .xml, .owl, .jsonld, .ttl, .obo)
rdf <- rdf_parse("FILEPATH")

## define SPARQL queries
# commented examples of how to use queries available here: https://www.w3.org/TR/sparql11-query/
# note: all terms/individuals are identified by an automatically generated Internationalized Resource Identifier (IRI), so to understand the results you have to print the corresponding rdfs:label value
# basic triples available: CharacterTag participatesTo RelationshipTag, CharacterTag/RelationshipTag isTaggedAs FreeformTag (plus inverse types and subclasses)

#query to get the available classes
query_classes <-
  'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>              # prefixes are useful to shorten the query
  PREFIX owl: <http://www.w3.org/2002/07/owl#>
  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
  PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
  SELECT ?subject_label                   # define which variables/values to print 
	  WHERE {
	  ?subject a owl:Class .                # define the type of variable you want to query
	  ?subject rdfs:label ?subject_label    # define a variable for the subject label, which will be printed to make the query results human-readable
	  }'

# query to get the releationships in which a character participates
# modify this to query for other types of triples
# currently there is an issue: if you don't get relationships for a character, query one of the character's synonyms
query_ships <-
  'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>              # prefixes are useful to shorten the query
  PREFIX owl: <http://www.w3.org/2002/07/owl#>
  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
  PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
  SELECT ?subject_label ?predicate_label ?object_label   # define which variables/values to print
	  WHERE { 
	  ?subject ?predicate ?object.                                        # define an empty triple
    ?subject rdfs:label ?subject_label .                                # define a variable for the subject label, which will be printed to make the query results human-readable
    ?object rdfs:label ?object_label .                                  # define a variable for the object label, which will be printed to make the query results human-readable
    ?predicate rdfs:label ?predicate_label .                            # define a variable for the predicate label, which will be printed to make the query results human-readable
    ?predicate rdfs:label "participatesTo" .                            # modify this to choose the predicate of the triple you want to query: participatesTo, hasParticipant, isTagOf, isTaggedAs
    ?isCanonical rdfs:label "isCanonical" .                             # define a variable for the predicate isCanonical
    ?subject ?isCanonical true .                                        # optional: show only canonical CharacterTags
    # ?object ?isCanonical true .                                       # optional: use this to see only canonical RelationshipTags (data for RelationshipTags with less than 1000 stories are not reliable)
    BIND (EXISTS{?subject ?isCanonical ?true} as ?canonical_label)      # optional: use this to see if a tag is canonical. Remember to add the variable ?canonical_label in the SELECT line
    FILTER regex(str(?subject_label), "Harry Potter") .                 # modify this to filter the subject you are interested in. Note that all occurrences of the term will be printed, for exact match use WHERE
    # FILTER regex(str(?object_label), "Draco Malfoy/Harry Potter")     # use this if you need to specify an object of the triple, instead of a subject. Remeber to change the predicate to hasParticipant
    }'

# query to get the synonyms of a tag
# modify this to query for other tags
query_synonyms <-
  'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>      # prefixes are useful to shorten the query
  PREFIX owl: <http://www.w3.org/2002/07/owl#>
  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
  PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
  SELECT ?subject_label ?synonym_label     #define which variables/values to print
	  WHERE { 
	  ?subject owl:sameAs ?synonym .                # define the triple for synonymity
    ?subject rdfs:label "Harry Potter" .          # define the tag for which you want to get the synonyms 
    ?subject rdfs:label ?subject_label .          # define a variable for the subject label, which will be printed to make the query results human-readable
    ?synonym rdfs:label ?synonym_label .          # define a variable for the synonym label, which will be printed to make the query results human-readable
    #FILTER regex(str(?synonym_label), "fem") .   # use and modify this to filter the synonyms you are interested in, e.g. tags for female Harry Potter characters
    }'


# perform queries and save outputs
classes <- rdf_query(rdf, query_classes)
HP_ships <- rdf_query(rdf, query_ships)
HP_synonyms <- rdf_query(rdf, query_synonyms)

