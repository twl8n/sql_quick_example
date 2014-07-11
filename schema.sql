


create table name_info (
       nid integer primary key autoincrement,
       name text,
       file text,
       norm text,
       first_word text,
       first_word_norm text
);


create index index1 on name_info (name);

-- Took around a minute, with the db full of 4.27M records
create index index2 on name_info (norm);

-- alter table name_info add column first_word text;
-- alter table name_info add column first_word_norm text;
