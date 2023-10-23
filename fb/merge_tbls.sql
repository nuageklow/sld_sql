

-- create post table
drop table fb_insight.post_insight;

CREATE TABLE IF NOT EXISTS fb_insight.post_insight(
  id text not null default ''::text,
  ex_account_id text null,
  fb_graph_node text null,
  parent_id text null,
  post_name text null,
  key1 text null,
  key2 text null,
  value text null,
  post_period text null,
  end_time text null,
  title text null,
  description text null
);



-- create info table
DROP TABLE IF EXISTS fb_insight.post_info;

CREATE TABLE IF NOT EXISTS fb_insight.post_info(
  id text NOT NULL DEFAULT ''::text,
  ex_account_id text null,
  fb_graph_node text null,
  parent_id text null,
  created_time text null,
  message text null
)


-- remove all comma and newline
sed -i -e 's/\r\n/""/g' data/post_info.csv
