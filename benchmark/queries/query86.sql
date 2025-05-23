-- start query 11 in stream 0 using template query86.tpl
select   
    sum(ws_net_paid) as total_sum
   ,i_category
   ,i_class
   ,grouping(i_category)+grouping(i_class) as lochierarchy
   ,rank() over (
 	partition by grouping(i_category)+grouping(i_class),
 	case when grouping(i_class) = 0 then i_category end 
 	order by sum(ws_net_paid) desc) as rank_within_parent
 from
    web_sales
   ,date_dim       d1
   ,item
 where
    d1.d_month_seq between 1205 and 1205+11
 and d1.d_date_sk = ws_sold_date_sk
 and i_item_sk  = ws_item_sk
 group by i_category, i_class with rollup
 order by
   lochierarchy desc,
   case when lochierarchy = 0 then i_category end,
   rank_within_parent
 limit 100;

-- end query 11 in stream 0 using template query86.tpl
