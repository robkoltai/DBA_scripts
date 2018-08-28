spool create_ts.lst
create temporary tablespace RK_temp_8x1_nvme_grouped_t1 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_01.dbf' size 4g autoextend off;

ALTER TABLESPACE  RK_temp_8x1_nvme_grouped_t1 TABLESPACE GROUP temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t2 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_02.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t3 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_03.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t4 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_04.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t5 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_05.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t6 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_06.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t7 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_07.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t8 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_08.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;

create temporary tablespace RK_temp_8x1_nvme_grouped_t9  tempfile '/nvmedisk/RK_temp_8x1_nvme_group_09.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t10 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_10.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t11 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_11.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t12 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_12.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t13 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_13.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t14 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_14.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t15 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_15.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t16 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_16.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;

create temporary tablespace RK_temp_8x1_nvme_grouped_t17 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_17.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t18 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_18.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t19 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_19.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t20 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_20.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t21 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_21.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t22 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_22.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t23 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_23.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t24 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_24.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t25 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_25.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t26 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_26.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t27 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_27.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t28 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_28.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t29 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_29.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t30 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_30.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t31 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_31.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t32 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_32.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t33 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_33.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t34 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_34.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t35 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_35.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t36 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_36.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t37 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_37.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t38 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_38.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t39 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_39.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t40 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_40.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t41 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_41.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t42 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_42.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t43 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_43.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t44 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_44.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t45 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_45.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t46 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_46.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t47 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_47.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t48 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_48.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t49 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_49.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t50 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_50.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t51 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_51.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t52 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_52.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t53 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_53.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t54 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_54.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t55 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_55.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t56 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_56.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t57 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_57.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t58 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_58.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t59 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_59.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t60 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_60.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t61 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_61.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t62 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_62.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t63 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_63.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;
create temporary tablespace RK_temp_8x1_nvme_grouped_t64 tempfile '/nvmedisk/RK_temp_8x1_nvme_group_64.dbf' size 4g autoextend off tablespace group temp_8x1_ts_group;



alter tablespace RK_temp_8x1_nvme_grouped_t1 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_01a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t2 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_02a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t3 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_03a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t4 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_04a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t5 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_05a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t6 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_06a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t7 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_07a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t8 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_08a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t9 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_09a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t10 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_10a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t11 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_11a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t12 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_12a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t13 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_13a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t14 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_14a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t15 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_15a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t16 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_16a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t17 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_17a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t18 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_18a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t19 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_19a.dbf' size 4g autoextend off;


alter tablespace RK_temp_8x1_nvme_grouped_t20 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_20a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t21 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_21a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t22 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_22a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t23 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_23a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t24 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_24a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t25 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_25a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t26 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_26a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t27 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_27a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t28 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_28a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t29 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_29a.dbf' size 4g autoextend off;

alter tablespace RK_temp_8x1_nvme_grouped_t30 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_30a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t31 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_31a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t32 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_32a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t33 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_33a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t34 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_34a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t35 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_35a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t36 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_36a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t37 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_37a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t38 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_38a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t39 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_39a.dbf' size 4g autoextend off;

alter tablespace RK_temp_8x1_nvme_grouped_t40 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_40a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t41 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_41a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t42 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_42a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t43 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_43a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t44 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_44a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t45 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_45a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t46 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_46a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t47 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_47a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t48 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_48a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t49 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_49a.dbf' size 4g autoextend off;

alter tablespace RK_temp_8x1_nvme_grouped_t50 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_50a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t51 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_51a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t52 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_52a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t53 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_53a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t54 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_54a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t55 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_55a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t56 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_56a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t57 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_57a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t58 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_58a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t59 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_59a.dbf' size 4g autoextend off;

alter tablespace RK_temp_8x1_nvme_grouped_t60 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_60a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t61 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_61a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t62 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_62a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t63 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_63a.dbf' size 4g autoextend off;
alter tablespace RK_temp_8x1_nvme_grouped_t64 add tempfile  '/nvmedisk/RK_temp_8x1_nvme_group_64a.dbf' size 4g autoextend off;
 
spool off;
