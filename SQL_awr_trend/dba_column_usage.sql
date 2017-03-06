/********************************************************************
 * File:	dba_column_usage.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:	11-Oct-04
 *
 * Restrictions:
 *	1. For Oracle9i v9.2 and above only
 *
 * Warning:
 *	This script is intended to create a view with a prefix of
 *	"DBA_", which would make the view seem to be normal part
 *	of the Oracle RDBMS.  It is recommended that this view
 *	be created as any schema other than SYS, so that any future
 *	addition of a view by this name shall not conflict with
 *	a patch or update to the Oracle data dictionary.
 *
 *	To make the underlying SYS tables "visible" to the schema
 *	under which this view is created, please grant the following
 *	explicit permissions:
 *
 *		GRANT SELECT ON SYS.COL_USAGE$ TO <schema-name>;
 *		GRANT SELECT ON SYS.OBJ$ TO <schema-name>;
 *		GRANT SELECT ON SYS.USER$ TO <schema-name>;
 *		GRANT SELECT ON SYS.COL$ TO <schema-name>;
 *
 * Description:
 *      Script to create a view named DBA_COLUMN_USAGE using the
 *	information contained in the table SYS.COL_USAGE$ which
 *	is populated by the cost-based optimizer in Oracle9i and
 *	above.
 *
 *	The SYS.COL_USAGE$ table is populated by the CBO with info
 *	about the usage of columns in the WHERE predicates of
 *	queries.  This information is utilized by certain procedures
 *	in the DBMS_STATS package with the prefix of "GATHER_" in
 *	their names.  When these procedures are called and the
 *	METHOD_OPT parameter ends with the phrase "SIZE AUTO", then
 *	the procedure gathers column-level histograms for columns in
 *	the table according to the following criteria:
 *		1. column is specified in the beginning of the
 *		   METHOD_OPT parameter using:
 *			a. FOR COLUMNS <column-list>
 *			b. FOR ALL COLUMNS
 *			c. FOR ALL INDEXED COLUMNS
 *		2. column contains "skewed" data as determined
 *		   using the "NTILE(<column-name>, 200)" functionality
 *		   used by the "SIZE SKEWONLY" specification
 *		3. column is has non-zero values in some of the
 *		   data stored in SYS.COL_USAGE$ table
 *
 *	The SYS.COL_USAGE$ table is also purged during SHUTDOWN NORMAL
 *	or SHUTDOWN IMMEDIATE, which sometimes causes long delays
 *	during shutdown if the database instance has been active for a
 *	long time.
 *
 * Modification:
 *      TGorman 11Oct04	written
 ********************************************************************/
set echo on feedback on timing on

spool dba_column_usage

show user
show release

create view dba_column_usage
as
select	oo.name owner,
	o.name,
	c.name column_name,
	u.equality_preds,
	u.equijoin_preds,
	u.nonequijoin_preds,
	u.range_preds,
	u.like_preds,
	u.null_preds,
	u.timestamp
from	sys.col_usage$ u,
	sys.obj$ o,
	sys.user$ oo,
	sys.col$ c
where	o.obj# = u.obj#
and	oo.user# = o.owner#
and	c.obj# = u.obj#
and	c.col# = u.intcol#;

create public synonym dba_column_usage for dba_column_usage;

spool off
