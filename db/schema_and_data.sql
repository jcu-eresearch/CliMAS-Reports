PRAGMA foreign_keys=OFF;

BEGIN TRANSACTION;

CREATE TABLE "region_types" (
    "regiontype" VARCHAR(16) NOT NULL,
    "regiontypename_singular" VARCHAR(32),
    "regiontypename_plural" VARCHAR(32),
    "regiontypeurl" VARCHAR(255),

    PRIMARY KEY("regiontype")
);

INSERT INTO "region_types" VALUES(
    'NRM',
    'Natural Resource Management (NRM) region',
    'Natural Resource Management (NRM) regions',
    'http://www.nrm.gov.au/about/nrm/regions/'
);
INSERT INTO "region_types" VALUES(
    'IBRA',
    'IBRA bioregion',
    'IBRA bioregions',
    'http://www.environment.gov.au/parks/nrs/science/bioregion-framework/ibra/'
);
INSERT INTO "region_types" VALUES('State',
    'state of Australia',
    'states of Australia',
    'http://www.gov.au/'
);
INSERT INTO "region_types" VALUES('National',
    'country',
    'countries',
    'http://australia.gov.au/'
);

CREATE TABLE "regions" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "type_local_code" VARCHAR(16),
    "shapefile_id" INTEGER,
    "name" VARCHAR(64),
    "long_name" VARCHAR(64),
    "state" VARCHAR(16),
    "governing_body" VARCHAR(128),
    "reportable" BOOLEAN,
    "includes_significant_sea" BOOLEAN,
    "region_type_regiontype" VARCHAR(16) NOT NULL
);

-- sql for inserting countries
INSERT INTO regions VALUES(1,null,null,'Australia','Australia',null,null,'t','t','National');

-- sql for inserting states
INSERT INTO regions VALUES(2,null,1,'New South Wales','New South Wales',null,null,'t','t','State');
INSERT INTO regions VALUES(3,null,2,'Victoria','Victoria',null,null,'t','t','State');
INSERT INTO regions VALUES(4,null,3,'Queensland','Queensland',null,null,'t','t','State');
INSERT INTO regions VALUES(5,null,4,'South Australia','South Australia',null,null,'t','t','State');
INSERT INTO regions VALUES(6,null,5,'Western Australia','Western Australia',null,null,'t','t','State');
INSERT INTO regions VALUES(7,null,6,'Tasmania','Tasmania',null,null,'t','t','State');
INSERT INTO regions VALUES(8,null,7,'Northern Territory','Northern Territory',null,null,'t','t','State');
INSERT INTO regions VALUES(9,null,8,'Australian Capital Territory','Australian Capital Territory',null,null,'t','f','State');
INSERT INTO regions VALUES(10,null,9,'Other Territories','Other Territories',null,null,'f','t','State');

-- sql for inserting NRM regions
INSERT INTO regions VALUES(12,null,0,'ACT','ACT Region','ACT','ACT Natural Resource Management Council','t','f','NRM');
INSERT INTO regions VALUES(13,null,1,'Adelaide and Mount Lofty Ranges','Adelaide and Mount Lofty Ranges Region','SA','Adelaide and Mount Lofty Ranges NRM Board','t','t','NRM');
INSERT INTO regions VALUES(14,null,2,'Alinytjara Wilurara','Alinytjara Wilurara Region','SA','Alinytjara Wilurara NRM Board','t','t','NRM');
INSERT INTO regions VALUES(15,null,3,'Ashmore and Cartier Islands','Ashmore and Cartier Islands Region','External Territory','Australian Government','f','t','NRM');
INSERT INTO regions VALUES(16,null,4,'Avon','Avon Region','WA','Wheatbelt Natural Resource Management','t','f','NRM');
INSERT INTO regions VALUES(17,null,5,'Border Rivers Maranoa-Balonne','Border Rivers Maranoa-Balonne Region','QLD','Queensland Murray-Darling Committee','t','f','NRM');
INSERT INTO regions VALUES(18,null,6,'Border Rivers-Gwydir','Border Rivers-Gwydir Region','NSW','Border Rivers-Gwydir CMA','t','f','NRM');
INSERT INTO regions VALUES(19,null,7,'Burdekin','Burdekin Region','QLD','North Queensland Dry Tropics NRM','t','t','NRM');
INSERT INTO regions VALUES(20,null,8,'Burnett Mary','Burnett Mary Region','QLD','Burnett Mary Regional Group for NRM','t','t','NRM');
INSERT INTO regions VALUES(21,null,9,'Cape York','Cape York Region','QLD','Cape York','t','t','NRM');
INSERT INTO regions VALUES(22,null,10,'Central West','Central West Region','NSW','Central West CMA','t','f','NRM');
INSERT INTO regions VALUES(23,null,11,'Christmas Island','Christmas Island Region','External Territory','Australian Government','f','t','NRM');
INSERT INTO regions VALUES(24,null,12,'Cocos Keeling Islands','Cocos Keeling Islands Region','External Territory','Australian Government','f','t','NRM');
INSERT INTO regions VALUES(25,null,13,'Condamine','Condamine Region','QLD','Condamine Alliance','t','f','NRM');
INSERT INTO regions VALUES(26,null,14,'Cooperative Management Area','Cooperative Management Area Region','QLD','Cape York and Northern Gulf Resource Management Group','f','t','NRM');
INSERT INTO regions VALUES(27,null,15,'Corangamite','Corangamite Region','VIC','Corangamite CMA','t','t','NRM');
INSERT INTO regions VALUES(28,null,16,'Desert Channels','Desert Channels Region','QLD','Desert Channels Queensland','t','f','NRM');
INSERT INTO regions VALUES(29,null,17,'East Gippsland','East Gippsland Region','VIC','East Gippsland CMA','t','t','NRM');
INSERT INTO regions VALUES(30,null,18,'Eyre Peninsula','Eyre Peninsula Region','SA','Eyre Peninsula NRM Board','t','t','NRM');
INSERT INTO regions VALUES(31,null,19,'Fitzroy','Fitzroy Region','QLD','Fitzroy Basin Association','t','t','NRM');
INSERT INTO regions VALUES(32,null,20,'Glenelg Hopkins','Glenelg Hopkins Region','VIC','Glenelg Hopkins CMA','t','t','NRM');
INSERT INTO regions VALUES(33,null,21,'Goulburn Broken','Goulburn Broken Region','VIC','Goulburn Broken CMA','t','f','NRM');
INSERT INTO regions VALUES(34,null,22,'Hawkesbury-Nepean','Hawkesbury-Nepean Region','NSW','Hawkesbury-Nepean CMA','t','t','NRM');
INSERT INTO regions VALUES(35,null,23,'Heard and McDonald Islands','Heard and McDonald Islands Region','External Territory','Australian Government','f','t','NRM');
INSERT INTO regions VALUES(36,null,24,'Hunter-Central Rivers','Hunter-Central Rivers Region','NSW','Hunter-Central Rivers CMA','t','t','NRM');
INSERT INTO regions VALUES(37,null,25,'Kangaroo Island','Kangaroo Island Region','SA','Kangaroo Island NRM Board','t','t','NRM');
INSERT INTO regions VALUES(38,null,26,'Lachlan','Lachlan Region','NSW','Lachlan CMA','t','f','NRM');
INSERT INTO regions VALUES(39,null,27,'Lower Murray Darling','Lower Murray Darling Region','NSW','Lower Murray Darling CMA','t','f','NRM');
INSERT INTO regions VALUES(40,null,28,'Mackay Whitsunday','Mackay Whitsunday Region','QLD','Reef Catchments Mackay Whitsunday Inc','t','t','NRM');
INSERT INTO regions VALUES(41,null,29,'Mallee','Mallee Region','VIC','Mallee CMA','t','f','NRM');
INSERT INTO regions VALUES(42,null,30,'Murray','Murray Region','NSW','Murray CMA','t','f','NRM');
INSERT INTO regions VALUES(43,null,31,'Murrumbidgee','Murrumbidgee Region','NSW','Murrumbidgee CMA','t','f','NRM');
INSERT INTO regions VALUES(44,null,32,'Namoi','Namoi Region','NSW','Namoi CMA','t','f','NRM');
INSERT INTO regions VALUES(45,null,33,'Norfolk Island','Norfolk Island Region','External Territory','Australian Government','f','t','NRM');
INSERT INTO regions VALUES(46,null,34,'North','North Region','TAS','NRM North','t','t','NRM');
INSERT INTO regions VALUES(47,null,35,'North Central','North Central Region','VIC','North Central CMA','t','f','NRM');
INSERT INTO regions VALUES(48,null,36,'North East','North East Region','VIC','North East CMA','t','f','NRM');
INSERT INTO regions VALUES(49,null,37,'North West','North West Region','TAS','NRM Cradle Coast','t','t','NRM');
INSERT INTO regions VALUES(50,null,38,'Northern Agricultural','Northern Agricultural Region','WA','Northern Agricultural Catchments Council','t','t','NRM');
INSERT INTO regions VALUES(51,null,39,'Northern Gulf','Northern Gulf Region','QLD','Northern Gulf Resource Management Group','t','t','NRM');
INSERT INTO regions VALUES(52,null,40,'Northern Rivers','Northern Rivers Region','NSW','Northern Rivers CMA','t','t','NRM');
INSERT INTO regions VALUES(53,null,41,'Northern Rivers - Lord Howe Island','Northern Rivers - Lord Howe Island Region','NSW','Northern Rivers CMA','t','t','NRM');
INSERT INTO regions VALUES(54,null,42,'Northern Territory','Northern Territory Region','NT','Natural Resource Management Board NT','t','t','NRM');
INSERT INTO regions VALUES(55,null,43,'Northern and Yorke','Northern and Yorke Region','SA','Northern and Yorke NRM Board','t','t','NRM');
INSERT INTO regions VALUES(56,null,44,'Perth','Perth Region','WA','Perth Region NRM','t','t','NRM');
INSERT INTO regions VALUES(57,null,45,'Port Phillip and Western Port','Port Phillip and Western Port Region','VIC','Port Phillip and Western Port CMA','t','t','NRM');
INSERT INTO regions VALUES(58,null,46,'Rangelands','Rangelands Region','WA','Rangelands NRM Co-ordinating Group','t','t','NRM');
INSERT INTO regions VALUES(59,null,47,'South','South Region','TAS','NRM South','t','t','NRM');
INSERT INTO regions VALUES(60,null,48,'South - Macquarie Islands','South - Macquarie Islands Region','TAS','NRM South','t','t','NRM');
INSERT INTO regions VALUES(61,null,49,'South Australian Arid Lands','South Australian Arid Lands Region','SA','South Australian Arid Lands NRM Board','t','f','NRM');
INSERT INTO regions VALUES(62,null,50,'South Australian Murray Darling Basin','South Australian Murray Darling Basin Region','SA','South Australian Murray Darling Basin NRM Board','t','t','NRM');
INSERT INTO regions VALUES(63,null,51,'South Coast','South Coast Region','WA','South Coast Natural Resource Management Inc','t','t','NRM');
INSERT INTO regions VALUES(64,null,52,'South East','South East Region','SA','South East NRM Board','t','t','NRM');
INSERT INTO regions VALUES(65,null,53,'South East Queensland','South East Queensland Region','QLD','South East Queensland Catchments','t','t','NRM');
INSERT INTO regions VALUES(66,null,54,'South West','South West Region','WA','South West Catchments Council','t','t','NRM');
INSERT INTO regions VALUES(67,null,55,'South West Queensland','South West Queensland Region','QLD','South West NRM','t','f','NRM');
INSERT INTO regions VALUES(68,null,56,'Southern Gulf','Southern Gulf Region','QLD','Southern Gulf Catchments','t','t','NRM');
INSERT INTO regions VALUES(69,null,57,'Southern Rivers','Southern Rivers Region','NSW','Southern Rivers CMA','t','t','NRM');
INSERT INTO regions VALUES(70,null,58,'Sydney Metro','Sydney Metro Region','NSW','Sydney Metro CMA','t','t','NRM');
INSERT INTO regions VALUES(71,null,59,'Torres Strait','Torres Strait Region','QLD','Torres Strait Regional Authority','t','t','NRM');
INSERT INTO regions VALUES(72,null,60,'West Gippsland','West Gippsland Region','VIC','West Gippsland CMA','t','t','NRM');
INSERT INTO regions VALUES(73,null,61,'Western','Western Region','NSW','Western CMA','t','f','NRM');
INSERT INTO regions VALUES(74,null,62,'Wet Tropics','Wet Tropics Region','QLD','Terrain NRM','t','t','NRM');
INSERT INTO regions VALUES(75,null,63,'Wimmera','Wimmera Region','VIC','Wimmera CMA','t','f','NRM');

-- sql for inserting IBRA regions
INSERT INTO regions VALUES(77,'ARC',1,'Arnhem Coast','Arnhem Coast Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(78,'ARP',2,'Arnhem Plateau','Arnhem Plateau Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(79,'AUA',3,'Australian Alps','Australian Alps Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(80,'AVW',4,'Avon Wheatbelt','Avon Wheatbelt Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(81,'BBN',5,'Brigalow Belt North','Brigalow Belt North Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(82,'BBS',6,'Brigalow Belt South','Brigalow Belt South Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(83,'BEL',7,'Ben Lomond','Ben Lomond Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(84,'BHC',8,'Broken Hill Complex','Broken Hill Complex Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(85,'BRT',9,'Burt Plain','Burt Plain Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(86,'CAR',10,'Carnarvon','Carnarvon Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(87,'CEA',11,'Central Arnhem','Central Arnhem Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(88,'CEK',12,'Central Kimberley','Central Kimberley Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(89,'CER',13,'Central Ranges','Central Ranges Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(90,'CHC',14,'Channel Country','Channel Country Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(91,'CMC',15,'Central Mackay Coast','Central Mackay Coast Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(92,'COO',16,'Coolgardie','Coolgardie Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(93,'COP',17,'Cobar Peneplain','Cobar Peneplain Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(94,'COS',18,'Coral Sea','Coral Sea Region',null,null,'f','t','IBRA');
INSERT INTO regions VALUES(95,'CYP',19,'Cape York Peninsula','Cape York Peninsula Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(96,'DAB',20,'Daly Basin','Daly Basin Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(97,'DAC',21,'Darwin Coastal','Darwin Coastal Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(98,'DAL',22,'Dampierland','Dampierland Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(99,'DEU',23,'Desert Uplands','Desert Uplands Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(100,'DMR',24,'Davenport Murchison Ranges','Davenport Murchison Ranges Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(101,'DRP',25,'Darling Riverine Plains','Darling Riverine Plains Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(102,'EIU',26,'Einasleigh Uplands','Einasleigh Uplands Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(103,'ESP',27,'Esperance Plains','Esperance Plains Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(104,'EYB',28,'Eyre Yorke Block','Eyre Yorke Block Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(105,'FIN',29,'Finke','Finke Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(106,'FLB',30,'Flinders Lofty Block','Flinders Lofty Block Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(107,'FUR',31,'Furneaux','Furneaux Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(108,'GAS',32,'Gascoyne','Gascoyne Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(109,'GAW',33,'Gawler','Gawler Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(110,'GES',34,'Geraldton Sandplains','Geraldton Sandplains Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(111,'GFU',35,'Gulf Fall and Uplands','Gulf Fall and Uplands Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(112,'GID',36,'Gibson Desert','Gibson Desert Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(113,'GSD',37,'Great Sandy Desert','Great Sandy Desert Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(114,'GUC',38,'Gulf Coastal','Gulf Coastal Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(115,'GUP',39,'Gulf Plains','Gulf Plains Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(116,'GVD',40,'Great Victoria Desert','Great Victoria Desert Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(117,'HAM',41,'Hampton','Hampton Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(118,'ITI',42,'Indian Tropical Islands','Indian Tropical Islands Region',null,null,'f','t','IBRA');
INSERT INTO regions VALUES(119,'JAF',43,'Jarrah Forest','Jarrah Forest Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(120,'KAN',44,'Kanmantoo','Kanmantoo Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(121,'KIN',45,'King','King Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(122,'LSD',46,'Little Sandy Desert','Little Sandy Desert Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(123,'MAC',47,'MacDonnell Ranges','MacDonnell Ranges Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(124,'MAL',48,'Mallee','Mallee Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(125,'MDD',49,'Murray Darling Depression','Murray Darling Depression Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(126,'MGD',50,'Mitchell Grass Downs','Mitchell Grass Downs Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(127,'MII',51,'Mount Isa Inlier','Mount Isa Inlier Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(128,'MUL',52,'Mulga Lands','Mulga Lands Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(129,'MUR',53,'Murchison','Murchison Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(130,'NAN',54,'Nandewar','Nandewar Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(131,'NCP',55,'Naracoorte Coastal Plain','Naracoorte Coastal Plain Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(132,'NET',56,'New England Tablelands','New England Tablelands Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(133,'NNC',57,'NSW North Coast','NSW North Coast Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(134,'NOK',58,'Northern Kimberley','Northern Kimberley Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(135,'NSS',59,'NSW South Western Slopes','NSW South Western Slopes Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(136,'NUL',60,'Nullarbor','Nullarbor Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(137,'OVP',61,'Ord Victoria Plain','Ord Victoria Plain Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(138,'PCK',62,'Pine Creek','Pine Creek Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(139,'PIL',63,'Pilbara','Pilbara Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(140,'PSI',64,'Pacific Subtropical Islands','Pacific Subtropical Islands Region',null,null,'f','t','IBRA');
INSERT INTO regions VALUES(141,'RIV',65,'Riverina','Riverina Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(142,'SAI',66,'Subantarctic Islands','Subantarctic Islands Region',null,null,'f','t','IBRA');
INSERT INTO regions VALUES(143,'SCP',67,'South East Coastal Plain','South East Coastal Plain Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(144,'SEC',68,'South East Corner','South East Corner Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(145,'SEH',69,'South Eastern Highlands','South Eastern Highlands Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(146,'SEQ',70,'South Eastern Queensland','South Eastern Queensland Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(147,'SSD',71,'Simpson Strzelecki Dunefields','Simpson Strzelecki Dunefields Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(148,'STP',72,'Stony Plains','Stony Plains Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(149,'STU',73,'Sturt Plateau','Sturt Plateau Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(150,'SVP',74,'Southern Volcanic Plain','Southern Volcanic Plain Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(151,'SWA',75,'Swan Coastal Plain','Swan Coastal Plain Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(152,'SYB',76,'Sydney Basin','Sydney Basin Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(153,'TAN',77,'Tanami','Tanami Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(154,'TCH',78,'Tasmanian Central Highlands','Tasmanian Central Highlands Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(155,'TIW',79,'Tiwi Cobourg','Tiwi Cobourg Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(156,'TNM',80,'Tasmanian Northern Midlands','Tasmanian Northern Midlands Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(157,'TNS',81,'Tasmanian Northern Slopes','Tasmanian Northern Slopes Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(158,'TSE',82,'Tasmanian South East','Tasmanian South East Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(159,'TSR',83,'Tasmanian Southern Ranges','Tasmanian Southern Ranges Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(160,'TWE',84,'Tasmanian West','Tasmanian West Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(161,'VIB',85,'Victoria Bonaparte','Victoria Bonaparte Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(162,'VIM',86,'Victorian Midlands','Victorian Midlands Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(163,'WAR',87,'Warren','Warren Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(164,'WET',88,'Wet Tropics','Wet Tropics Region',null,null,'t','f','IBRA');
INSERT INTO regions VALUES(165,'YAL',89,'Yalgoo','Yalgoo Region',null,null,'t','f','IBRA');


DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" VALUES('regions',1);
CREATE INDEX "index_regions_region_type" ON "regions" ("region_type_regiontype");

COMMIT;
