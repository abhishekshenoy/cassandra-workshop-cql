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

##Check for data
Select * from product;

#Insert data
insert into product(productid, title, publisher) values('LATHE2', 'Strong lathe', 'Kiosk');

## To add column modelid of type text
ALTER COLUMNFAMILY product add modelid text;

## To describe  column family product
DESCRIBE product;

## to describe keyspace catalog
DESCRIBE KEYSPACE catalog;

## To add few rows to product column family
insert into product(productid, brand, modelid) values('LATHE1', 'Mitsbushi', 'M100');
insert into product(productid, title, breadth, length) values('MOTOR1', 'AC motor', 22, 36);
insert into product(productid, title, breadth, length) values('MOTOR2', 'DC Motor', 22, 36);

## To show column family data
select * from product;

## To show row for a productid with EQ 
select * from product where productid = 'LATHE1';

## To show row for a productid with IN 
select productid, title, modelid from product where productid IN ('LATHE1', 'MOTOR1');

## To add column with data type SET
ALTER COLUMNFAMILY product ADD keyfeatures set<TEXT>;

##To insert product with set data type
insert into product(productid, title, brand, keyfeatures) values('Nut1', 'Threaded Nut', 'Tej', {'detachable', 'colorful'}); 

## To add column with data type MAP
ALTER COLUMNFAMILY product ADD camera map<TEXT, TEXT>;

##Dropping a column
ALTER COLUMNFAMILY product DROP camera;

## To add column with data type MAP
ALTER COLUMNFAMILY product ADD properties map<TEXT, TEXT>;

##To insert product with map data type
insert into product(productid, title, brand, properties) values('Cement', 'Sets quickly', 'Ambuja', {'Strength':'Standard autoclave test passed', 'Setting Time':'650 minutes'});

## To add column with data type LIST
ALTER COLUMNFAMILY product ADD service_type LIST<TEXT>;

##To insert product with list data type
insert into product(productid, title, brand, service_type) values('SOFA1', 'Urban Living Derby Sofa', 'Urban Living', ['Needs to call seller', 'Service Engineer will Come to the Site ']);


-----------------------------Partition Key Restrictions------------------------------

#Allow Filtering issue because partition key not included
select productid from product where publisher = 'Kiosk';

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

## To load data from file skus.csv into skus Column Family
COPY skus(sellerid, productid, skuid, title,listingid, islistingcreated,timeofskucreation) FROM 'seller.csv' ;

## To show data of skus
select * from skus;

##Won t work unless All partition keys included
select * from skus where sellerid= 'Decor';

##All partition keys included
select * from skus where sellerid= 'Decor' and skuid='DECORSKU';

## To allow filtering
select * from skus where productid > 'SOFA1' ALLOW FILTERING;

##Won t work unless All partition keys are needed even with in
select * from skus where sellerid in ('Decor');

##All partition keys included
select * from skus where sellerid in ('Decor') and skuid in ('DECORSKU');

##Cannot use >,>=,<,<= operator directly in partition key
select * from skus where sellerid > 'Chroma' and skuid > 'ChromaSKU1';

##OrderBy Not supported without resticted partition columns
select * from skus order by sellerid;

## To do range query using > on token(partition key)
select * from skus where token(sellerid,skuid) >= token('Chroma', 'ChromaSKU1') ;


--------------------------Clustering Key Restrictions----------------------------------


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
