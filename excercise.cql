


## To login cqlsh
cqlsh -u cassandra -p cassandra 

## Create keyspace catalog
CREATE KEYSPACE catalog WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}  AND durable_writes = true;

 
## To list keyspaces:
DESCRIBE keyspaces;

## To list all columnfamilies in catalog keyspace:
USE catalog;
describe columnfamilies;

## To create columnfamily product
CREATE COLUMNFAMILY product (	
  productId varchar,
  title TEXT,
  brand varchar,
  publisher varchar,
  length int,
  breadth int,
  height int,
  PRIMARY KEY  (productId) );

## To create columnfamily skus
CREATE TABLE skus (
   sellerId varchar,
   productId varchar,
   skuId varchar,
   title text,
   listingId varchar,
   isListingCreated boolean,
   timeofskucreation text,
   PRIMARY KEY((sellerId,skuId), timeofskucreation, productId)
  );

## To add column modelid of type text
ALTER COLUMNFAMILY product add modelid text;

## To change gc_grace_seconds to 1 day
ALTER COLUMNFAMILY product WITH gc_grace_seconds=86400;

## To describe  column family product
DESCRIBE product;

## to describe keyspace catalog
DESCRIBE KEYSPACE catalog;

## Altering the replication index of keyspace
ALTER KEYSPACE "catalog" WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 2};


## To add row to product column family
insert into product(productid, brand, modelid) values('LATHE1', 'Samsung', 'GalaxyS6');
insert into product(productid, title, publisher) values('LATHE2', 'The Kite Runner', 'Riverbed Books');
insert into product(productid, title, breadth, length) values('MOTOR1', 'led zeppelin', 22, 36) USING TIMESTAMP 1468580580000;
insert into product(productid, title, breadth, length) values('MOTOR2', 'adele', 22, 36) USING TTL 86400;

## To show column family data
select * from product;

## To show row for a productid with EQ 
select * from product where productid = 'POST1';

## To show row for a productid with IN 
select productid, title, modelid from product where productid IN ('POST1', 'MOB1');

## To add column with data type SET
ALTER COLUMNFAMILY product ADD keyfeatures set<TEXT>;

## To add column with data type MAP
ALTER COLUMNFAMILY product ADD camera map<TEXT, TEXT>;

## To add column with data type LIST
ALTER COLUMNFAMILY product ADD service_type LIST<TEXT>;

##To insert product with set data type
insert into product(productid, title, brand, keyfeatures) values('COM1', 'Acer ONE', 'ACER', {'detachable keyboard', 'multitouch display'}); 

##To insert product with list data type
insert into product(productid, title, brand, service_type) values('SOFA1', 'Urban Living Derby Sofa', 'Urban Living', ['Needs to call seller', 'Service Engineer will Come to the Site ']);

##To insert product with map data type
insert into product(productid, title, brand, camera) values('COM1', 'Acer ONE', 'ACER', {'front':'VGA', 'rear':'2MP'});

## To update modelId of MOB1
update product set modelid = 'S6' where productid = 'MOB1';

## To update multiple columns and with IN
update product set breadth = 18, length = 25, height = 2 where productid in ('COM1', 'COM2');

## To add element to list
update product set service_type = service_type + ['Service engineer will inspect the damages'] where productid = 'SOFA1';

## To remove element from list
update product set service_type = service_type - ['Needs to call seller'] where productid = 'SOFA1';

## To replace element in list
update product set service_type[1] = 'service engineer will call for appointment' where productid = 'SOFA1';

## To add element to set
update product USING TTL 86400 set keyfeatures = keyfeatures + {'FLAT 10% off for 1 day'} where productid IN ('COM1', 'COM2');

## To remove element from set
update product USING TTL 86400 set keyfeatures = keyfeatures - {'detachable keyboard'} where productid IN ('COM1', 'COM2');

## To add element to map
update product set camera = camera + {'frontVideo':'1MP'} where productid = 'COM1';

## To remove element from map
delete camera['frontVideo'] from product where productid = 'COM1';

## To replace element in map
update product set camera['front'] = '1MP' where productid = 'COM1';

-----------------------------Partition Key Restrictions------------------------------

#Allow Filtering issue because partition key not included
select productid from product where publisher = 'Riverhead';

## To load data from file skus.csv into skus Column Family
COPY skus(sellerid, productid, skuid, title,listingid, islistingcreated,timeofskucreation) FROM 'skus.csv' ;

## To show data of skus
select * from skus;

##All partition keys included
select * from skus where sellerid= 'Decor';

##All partition keys are needed even with in
select * from skus where sellerid in ('Decor');

##Cannot use >,>=,<,<= operator directly in partition key
select * from skus where sellerid > 'Chroma' and skuid > 'ChromaSKU1';

##OrderBy Not supported without resticted partition columns
select * from skus order by sellerid;

##OrderBy by supported only on clustered columns
select * from skus where sellerid IN ('Decor', 'Fab') and skuid IN ('FABSKU', 'DECORSKU') order by sellerid;

## To do range query using > on token(partition key)
select * from skus where token(sellerid,skuid) >= token('Chroma', 'ChromaSKU1') ;

## To query skus with restricted partition key
select * from skus where sellerid IN ('Decor', 'Fab') and skuid IN ('FABSKU', 'DECORSKU');

--------------------------Clustering Key Restrictions----------------------------------

##Ordering of clustereing key
select * from skus where sellerid = 'Fab' and skuid = 'FABSKU';

##Require 1 to n-1  clustering keys
select * from skus where sellerid = 'Fab' and skuid in ('FABSKU', 'FABSKU1') and productid = 'SOFA1';

##Whereas giving only the first clustering column works 
select * from skus where sellerid = 'Fab' and skuid in ('FABSKU', 'FABSKU1') and timeofskucreation = '2015-12-11 12:21';

## To query successfully with clustering keys with EQ on skus
select * from skus where sellerid = 'Fab' and skuid in ('FABSKU', 'FABSKU1') and timeofskucreation = '2015-12-11 12:21' and productid = 'SOFA1';

## To query successfully with clustering keys with IN on skus
select * from skus where sellerid in ('Decor', 'Fab') and skuid in ('FABSKU', 'DECORSKU') and timeofskucreation IN ('2015-12-11 12:21', '2016-07-01 22:30') AND 
productid in ('SOFA1', 'SOFA2');

## To query by restricting the clustering columns with range operator
select * from skus where sellerid in ('Decor', 'Fab') and skuid in ('FABSKU', 'DECORSKU') and timeofskucreation >= '2015-08-01 12:21' AND timeofskucreation
<= '2016-07-01 22:30'; 

## To allow filtering
select * from skus where productid > 'SOFA1' ALLOW FILTERING;
