-- PostgreSQL syntax

create table Crew (
	id Serial primary key,
	fullName Text not null,
	name Text not null,
	role Text not null
);

insert into Crew (fullName, name, role) values ('Malcolm Reynolds', 'Mal', 'Captain');
insert into Crew (fullName, name, role) values ('Zoë Alleyne', 'Zoë', 'First mate');
insert into Crew (fullName, name, role) values ('Hoban Washburne', 'Wash', 'Pilot');
insert into Crew (fullName, name, role) values ('Kaywinnet Lee Frye' ,'Kaylee', 'Mechanic');
insert into Crew (fullName, name, role) values ('River Tam', 'River', 'Martial Ass-kicker');
insert into Crew (fullName, name, role) values ('Inara Serra', 'Inara', 'Companion');
insert into Crew (fullName, name, role) values ('Simon Tam', 'Simon', 'Medic');
insert into Crew (fullName, name, role) values ('Jayne Cobb', 'Jayne', 'Mercenary');

create table TestData (
	id Serial primary key,
	string Text null,
	data ByteA null,
	double Real null
);

insert into TestData (string) values ('text_only');
insert into TestData (data) values (E'\\x646174615f6f6e6c79');
insert into TestData (double) values (3.0);
