//objectcomments Distributed PB example User object used by client and server (remote object)
forward
global type uo_sales_order from nvo_database
end type
end forward

global type uo_sales_order from nvo_database
string ProxyName="ro_sales_order"
end type
global uo_sales_order uo_sales_order

type prototypes

end prototypes

type variables
DataStore  ids_product
DataStore  ids_sales_order
DataStore  ids_customer
DataStore  ids_employees
DataStore  ids_lib_list
DataStore  ids_sales_order_item
DataStore ids_data

string is_reportfile="pbexdpbr.pbl"
end variables

forward prototypes
private function integer of_retrieve_sales ()
public function boolean of_get_sales_order (integer ai_order_id, ref s_sales_order astr_order)
public function integer of_get_all_sales_orders (ref s_sales_order astr_order[])
public function integer of_get_customers (ref s_customer astr_cuntomer[])
public function integer of_retrieve_customers ()
public function integer of_retrieve_employees ()
public function integer of_get_all_sales_reps (ref string as_reps[])
public function string of_get_all_sales_orders (date adt_date, integer ai_direction)
public function string of_get_all_sales_orders ()
public function integer of_get_all_sales_orders (ref s_sales_order astr_order[], date adt_date, integer ai_direction)
public function string of_get_all_sales_orders (date adt_date, integer ai_direction, integer ai_option)
public function string of_get_all_sales_reps (int al_sales_order)
public function string of_get_customers (integer al_sales_order)
public function string of_get_all_sales_reps (string as_rep)
private function integer of_retrieve_product ()
public function string of_get_product_info (long al_id)
private function integer of_retrieve_sales_items ()
public function string of_get_sales_order (integer ai_order_id)
public function string of_retrieve_report (string as_datasource)
public function integer of_get_all_saleorders_id (ref long al_id[])
public function integer of_get_all_saleorders_id (date adt_date, integer ai_direction, ref long al_id[])
public function string of_get_syntax (string as_datasource)
public function integer of_get_report_list (ref string as_datasource[], ref string as_comment[])
end prototypes

private function integer of_retrieve_sales ();int li_rc

// retrieve sales order data

li_rc = ids_sales_order.settransobject(invo_transaction)
if NOT li_rc >0 THEN
	return 0
end if

li_rc = ids_sales_order.retrieve()
if NOT li_rc >0 THEN
	return 0
end if

return li_rc


end function

public function boolean of_get_sales_order (integer ai_order_id, ref s_sales_order astr_order);// get the sales order by number and populate passed in structure
long ll_row, ll_row_count

ll_row_count = ids_sales_order.rowcount()

if NOT ll_row_count >0 THEN
	if of_retrieve_sales() >0 THEN
		return false
	end if
	
end if

ll_row = ids_sales_order.find("id = "+string(ai_order_id), 1, ll_row_count)

if ll_row > 0 THEN
	astr_order.id = ids_sales_order.object.id[ll_row]
	astr_order.cust_id = ids_sales_order.object.cust_id[ll_row] 
	astr_order.order_date = ids_sales_order.object.order_date[ll_row]
	astr_order.fin_code_id = ids_sales_order.object.fin_code_id[ll_row]
	astr_order.region = ids_sales_order.object.region[ll_row]
	astr_order.sales_rep = ids_sales_order.object.sales_rep[ll_row]
else
	return false
end if



end function

public function integer of_get_all_sales_orders (ref s_sales_order astr_order[]);/////////////////////////////////////////////////////////////////////////////
//	Function:  of_get_sales_orders
//
//	Access:  public
//
//	Arguments:
//	adt_date - date used to filter for ai_direction
// ai_direction - direction to filter; -1=before adt_date, 1=after adt_date
// ai_option - reserved
//
//	Returns:  count for rows
//
//	Description:
// gets all the sales data and populate passed in structure
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	5.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
//	Copyright © 1996 Powersoft Corporation.  All Rights Reserved.
//
//////////////////////////////////////////////////////////////////////////////

int 	li_i
long ll_row, ll_row_count

ll_row_count = ids_sales_order.rowcount()

if ll_row_count <= 0 THEN
	ll_row_count = of_retrieve_sales()
	if ll_row_count <= 0 THEN
		return 0
	end if
	
end if

astr_order = ids_sales_order.object.data.primary

return ll_row_count
end function

public function integer of_get_customers (ref s_customer astr_cuntomer[]);// get customers and populate passed in structure

int 	li_i
long ll_row, ll_row_count

ll_row_count = ids_customer.rowcount()

if NOT ll_row_count >0 THEN
	ll_row_count = of_retrieve_customers()
	if NOT  ll_row_count>0 THEN
		return 0
	end if
	
end if

astr_cuntomer = ids_customer.object.data.primary


return ll_row_count 

 


end function

public function integer of_retrieve_customers ();int li_rc

// retrieve sales order data
li_rc = ids_customer.settransobject(invo_transaction)

if NOT li_rc >0 THEN
			return 0
end if

	

li_rc = ids_customer.retrieve()
if NOT li_rc >0 THEN
	return 0
end if

return li_rc


end function

public function integer of_retrieve_employees ();int li_rc

// retrieve employee data
if li_rc = 0 THEN
	li_rc = ids_employees.settransobject(invo_transaction)
		if NOT li_rc >0 THEN
			return 0
		end if
end if
	

li_rc = ids_employees.retrieve()
if NOT li_rc >0 THEN
	return 0
end if

return li_rc


end function

public function integer of_get_all_sales_reps (ref string as_reps[]);// get all the sales reps and populate passed in array

long ll_row_count
int li_i
int li_rc

ll_row_count = ids_employees.rowcount()

if ll_row_count <= 0 THEN
	ll_row_count = of_retrieve_employees()
	if ll_row_count <= 0 THEN
		return 0
	end if
	
end if


li_rc =  ids_employees.setfilter("dept_id = 200")
li_rc =  ids_employees.filter()

ll_row_count =  ids_employees.rowcount()


as_reps = ids_employees.object.emp_lname.primary


return ll_row_count




end function

public function string of_get_all_sales_orders (date adt_date, integer ai_direction);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_get_sales_orders
//
//	Access:  public
//
//	Arguments:
//	adt_date - date used to filter for ai_direction
// ai_direction - direction to filter; -1=before adt_date, 1=after adt_date
//
//	Returns:  string
//         sales related data in ~t between columns, and ~r~n for each row format
//
//	Description:
// gets all the sales data  before or after passed in date 
// and create a string to return to caller
// the returend string can be imported into a datawindow/datastore
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	5.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
//	Copyright © 1996 Powersoft Corporation.  All Rights Reserved.
//
//////////////////////////////////////////////////////////////////////////////
string ls_filter

int 	li_i
long ll_row, ll_row_count
string ls_return

// make sure all the data is in the primary buffer
ids_sales_order.setfilter("")
ids_sales_order.filter()

ll_row_count = ids_sales_order.rowcount()

if NOT ll_row_count >0 THEN
	ll_row_count = of_retrieve_sales()
	if  NOT ll_row_count>0 THEN
		return ""
	end if
	
end if




// filter datastore
if ai_direction = -1 THEN
		ls_filter = "order_date <= "+string(adt_date)
	else
		ls_filter = "order_date => "+string(adt_date)
end if
	
ids_sales_order.filter()

ll_row_count = ids_sales_order.rowcount()

if ll_row_count > 0 THEN
	
	FOR li_i=1  TO ll_row_count
		ls_return += string(ids_sales_order.object.id[li_i])+"~t"
		ls_return += string(ids_sales_order.object.cust_id[li_i])+"~t"
		ls_return += ids_sales_order.object.fin_code_id[li_i]+"~t"
		ls_return += ids_sales_order.object.region[li_i]+"~t"
		ls_return += string(ids_sales_order.object.sales_rep[li_i])+"~t"
		ls_return += string(date(ids_sales_order.object.order_date[li_i]))+"~r~n"
	NEXT
	return ls_return 
else
	return ""
end if

end function

public function string of_get_all_sales_orders ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_get_sales_orders
//
//	Access:  public
//
//	Arguments:none
//
//	Returns:  string
//         sales related data in ~t between columns, and ~r~n for each row
//
//	Description:
// gets all the sales data and create a string to return to caller
// the returend string can be imported into a datawindow/datastore
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	5.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
//	Copyright © 1996 Powersoft Corporation.  All Rights Reserved.
//
//////////////////////////////////////////////////////////////////////////////
int 	li_i
long ll_row, ll_row_count
string ls_return

ll_row_count = ids_sales_order.rowcount()

if NOT ll_row_count >0 THEN
	ll_row_count = of_retrieve_sales()
	if  NOT ll_row_count>0 THEN
		return ""
	end if
	
end if

FOR li_i=1  TO ll_row_count
	ls_return += string(ids_sales_order.object.id[li_i])+"~t"
	ls_return += string(ids_sales_order.object.cust_id[li_i])+"~t"
	ls_return += ids_sales_order.object.fin_code_id[li_i]+"~t"
	ls_return += ids_sales_order.object.region[li_i]+"~t"
	ls_return += string(ids_sales_order.object.sales_rep[li_i])+"~t"
	ls_return += string(date(ids_sales_order.object.order_date[li_i]))+"~r~n"
NEXT

return ls_return 

end function

public function integer of_get_all_sales_orders (ref s_sales_order astr_order[], date adt_date, integer ai_direction);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_get_sales_orders
//
//	Access:  public
//
//	Arguments:
// astr_order[] - array of sales orders
//	adt_date - date used to filter for ai_direction
// ai_direction - direction to filter; -1=before adt_date, 1=after adt_date
//
//	Returns:  count of rows
//        
//
//	Description:
// gets all the sales data  before or after passed in date 
// and populate the passed in array.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	5.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
//	Copyright © 1996 Powersoft Corporation.  All Rights Reserved.
//
//////////////////////////////////////////////////////////////////////////////
string ls_filter
int 	li_i
long ll_row, ll_row_count

// make sure all the data is in the primary buffer
ids_sales_order.setfilter("")
ids_sales_order.filter()


ll_row_count = ids_sales_order.rowcount()

if ll_row_count <= 0 THEN
	ll_row_count = of_retrieve_sales()
	if ll_row_count <= 0 THEN
		return 0
	end if
	
end if



// filter datastore
if ai_direction = -1 THEN
		ls_filter = "order_date <= "+string(adt_date)
	else
		ls_filter = "order_date => "+string(adt_date)
end if
	
ids_sales_order.filter()

astr_order = ids_sales_order.object.data.primary

return ll_row_count
end function

public function string of_get_all_sales_orders (date adt_date, integer ai_direction, integer ai_option);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_get_sales_orders
//
//	Access:  public
//
//	Arguments:
//	adt_date - date used to filter for ai_direction
// ai_direction - direction to filter; -1=before adt_date, 1=after adt_date
// ai_option - reserved
//
//	Returns:  string
//         sales related data in ~t between columns, and ~r~n for each row
//
//	Description:
// gets all the sales data  before or after passed in date 
// and create a string to return to caller
// the returend string can be imported into a datawindow/datastore
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	5.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
//	Copyright © 1996 Powersoft Corporation.  All Rights Reserved.
//
//////////////////////////////////////////////////////////////////////////////
string ls_filter

int 	li_i
long ll_row, ll_row_count
string ls_return


// make sure all the data is in the primary buffer
ids_sales_order.setfilter("")
ids_sales_order.filter()

ll_row_count = ids_sales_order.rowcount()

if NOT ll_row_count >0 THEN
	ll_row_count = of_retrieve_sales()
	if  NOT ll_row_count>0 THEN
		return ""
	end if
	
end if




// filter datastore
if ai_direction = -1 THEN
		ls_filter = "order_date <= "+string(adt_date)
	else
		ls_filter = "order_date => "+string(adt_date)
end if
	
ids_sales_order.filter()

ll_row_count = ids_sales_order.rowcount()

if ll_row_count > 0 THEN
	
	FOR li_i=1  TO ll_row_count
		ls_return += string(ids_sales_order.object.id[li_i])+"~t"
		ls_return += string(ids_sales_order.object.cust_id[li_i])+"~t"
		ls_return += ids_sales_order.object.fin_code_id[li_i]+"~t"
		ls_return += ids_sales_order.object.region[li_i]+"~t"
		ls_return += string(ids_sales_order.object.sales_rep[li_i])+"~t"
		ls_return += string(date(ids_sales_order.object.order_date[li_i]))+"~r~n"
	NEXT
	return ls_return 
else
	return ""
end if

end function

public function string of_get_all_sales_reps (int al_sales_order);// get all the sales reps and populate passed in array
string ls_data
long ll_row, ll_row_count
long ll_rep_id
string ls_find 

// get the sales rep id from the sales order data

// first make sure there is data for sales orders
if  ids_sales_order.rowcount() <= 0 THEN
	ll_row_count = of_retrieve_sales()
	if ll_row_count <= 0 THEN
		return ""
	end if
else 
	ll_row_count = ids_sales_order.rowcount()
end if

ls_find = "id = "+string(al_sales_order)

ll_row = ids_sales_order.find(ls_find ,1, ll_row_count)

if ll_row >0 THEN
	ll_rep_id = ids_sales_order.object.sales_rep[ll_row]
else
	return ""
end if

if  ids_employees.rowcount() <= 0 THEN
	ll_row_count = of_retrieve_employees ( )
	if ll_row_count <= 0 THEN
		return ""
	end if
end if

ll_row = ids_employees.find("emp_id = "+string(ll_rep_id), 1, ll_row_count)

if ll_row >0 THEN
	ls_data += string(ids_employees.object.emp_id[ll_row])+"~t"
	ls_data += ids_employees.object.emp_fname[ll_row]+"~t"
	ls_data += ids_employees.object.emp_lname[ll_row]+"~t"
	ls_data += ids_employees.object.phone[ll_row]+"~t"
end if

return ls_data







end function

public function string of_get_customers (integer al_sales_order);// get all the sales reps and populate passed in array
string ls_data
long ll_row, ll_row_count
long ll_cust_id
string ls_find 

// get the customer id from the sales order data

// first make sure there is data for sales orders
if  ids_sales_order.rowcount() <= 0 THEN
	ll_row_count = of_retrieve_sales()
	if ll_row_count <= 0 THEN
		return ""
	end if
else 
	ll_row_count = ids_sales_order.rowcount()
end if

ls_find = "id = "+string(al_sales_order)

ll_row = ids_sales_order.find(ls_find ,1, ll_row_count)

if ll_row >0 THEN
	ll_cust_id = ids_sales_order.object.cust_id[ll_row]
else
	return ""
end if

if  ids_customer.rowcount() <= 0 THEN
	ll_row_count = of_retrieve_customers ( )
	if ll_row_count <= 0 THEN
		return ""
	end if
end if

ls_find = "id = "+string(ll_cust_id)

ll_row = ids_customer.find(ls_find, 1, ll_row_count)

if ll_row >0 THEN
	ls_data += string(ids_customer.object.id[ll_row])+"~t"
	ls_data += ids_customer.object.fname[ll_row]+"~t"
	ls_data += ids_customer.object.lname[ll_row]+"~t"
	ls_data += ids_customer.object.address[ll_row]+"~t"
	ls_data += ids_customer.object.city[ll_row]+"~t"
	ls_data += ids_customer.object.state[ll_row]+"~t"
	ls_data += ids_customer.object.zip[ll_row]+"~t"
	ls_data += ids_customer.object.phone[ll_row]+"~t"
end if

return ls_data







end function

public function string of_get_all_sales_reps (string as_rep);// get all the sales reps and populate passed in array
string ls_data
long ll_row, ll_row_count
long ll_rep_id
string ls_find 

if  ids_employees.rowcount() <= 0 THEN
	ll_row_count = of_retrieve_employees ( )
	if ll_row_count <= 0 THEN
		return ""
	end if
else
	ll_row_count = ids_employees.rowcount()
end if

ll_row = ids_employees.find("emp_lname = "+"'"+as_rep+"'", 1, ll_row_count)

if ll_row >0 THEN
	ls_data += string(ids_employees.object.emp_id[ll_row])+"~t"
	ls_data += ids_employees.object.emp_fname[ll_row]+"~t"
	ls_data += ids_employees.object.emp_lname[ll_row]+"~t"
	ls_data += ids_employees.object.street[ll_row]+"~t"
	ls_data += ids_employees.object.city[ll_row]+"~t"
	ls_data += ids_employees.object.state[ll_row]+"~t"
	ls_data += ids_employees.object.zip_code[ll_row]+"~t"
	ls_data += ids_employees.object.phone[ll_row]+"~t"
	ls_data += ids_employees.object.status[ll_row]+"~t"
	
end if

return ls_data






end function

private function integer of_retrieve_product ();int li_rc

// retrieve sales order data

li_rc = ids_product.settransobject(invo_transaction)
if NOT li_rc >0 THEN
	return 0
end if

li_rc = ids_product.retrieve()
if NOT li_rc >0 THEN
	return 0
end if

return li_rc


end function

public function string of_get_product_info (long al_id);// get product information for sales order id passed in parm.
// 
string ls_data
long ll_row_item, ll_row_prod, ll_row_count
long ll_prod_id
string ls_find 

// get product id from  sales order items

// first make sure there is data for sales orders
if  ids_sales_order_item.rowcount() <= 0 THEN
	ll_row_count = of_retrieve_sales_items ( )
	if ll_row_count <= 0 THEN
		return ""
	end if
else 
	ll_row_count = ids_sales_order_item.rowcount()
end if

ls_find = "sales_order_items_id = "+string(al_id)

ll_row_item = ids_sales_order_item.find(ls_find ,1, ll_row_count)

if ll_row_item >0 THEN
	ll_prod_id = ids_sales_order_item.object.sales_order_items_prod_id[ll_row_item] 
else
	return ""
end if


if  ids_product.rowcount() <= 0 THEN
	ll_row_count = of_retrieve_product ( )
	if ll_row_count <= 0 THEN
		return ""
	end if
end if

ls_find = "id = "+string(ll_prod_id)

ll_row_prod = ids_product.find(ls_find, 1, ll_row_count)

if ll_row_prod >0 THEN
	ls_data += ids_product.object.description[ll_row_prod]+"~t"
	ls_data += ids_product.object.name[ll_row_prod]+"~t"
	ls_data += string(ids_sales_order_item.object.sales_order_items_quantity[ll_row_item])+"~t"
	ls_data += string(ids_sales_order_item.object.sales_order_items_ship_date[ll_row_item])+"~t"
	ls_data += string(ids_product.object.id[ll_row_prod])+"~t"
end if

return ls_data







return ""
end function

private function integer of_retrieve_sales_items ();int li_rc

// retrieve sales order item data

li_rc = ids_sales_order_item.settransobject(invo_transaction)
if NOT li_rc >0 THEN
	return 0
end if

li_rc = ids_sales_order_item.retrieve()
if NOT li_rc >0 THEN
	return 0
end if

return li_rc


end function

public function string of_get_sales_order (integer ai_order_id);// get the sales order item by number and create string to return to caller
// get all the sales reps and populate passed in array
string ls_data
long ll_row, ll_row_count
long ll_prod_id
string ls_find 

// first make sure there is data for sales orders items
if  ids_sales_order_item.rowcount() <= 0 THEN
	ll_row_count = of_retrieve_sales_items ( )
	if ll_row_count <= 0 THEN
		return ""
	end if
else 
	ll_row_count = ids_sales_order_item.rowcount()
end if

ls_find = "id = "+string(ai_order_id)

ll_row = ids_sales_order_item.find(ls_find ,1, ll_row_count)

if ll_row >0 THEN
	ll_prod_id = ids_sales_order_item.object.sales_order_items_prod_id[ll_row]
else
	return ""
end if

if  ids_product.rowcount() <= 0 THEN
	ll_row_count = of_retrieve_product( )
	if ll_row_count <= 0 THEN
		return ""
	end if
end if

ls_find = "id = "+string(ll_prod_id)

ll_row = ids_product.find(ls_find, 1, ll_row_count)

if ll_row >0 THEN
	ls_data += ids_product.object.product_description[ll_row]+"~t"
	ls_data += ids_product.object.product_name[ll_row]+"~t"
	ls_data += string(ids_product.object.sales_order_items_quantity[ll_row])+"~t"
	ls_data += string(ids_product.object.sales_order_items_ship_date[ll_row])+"~t"
	ls_data += string(ids_product.object.sales_order_items_prod_id[ll_row])+"~t"
end if

return ls_data







return ""


end function

public function string of_retrieve_report (string as_datasource);// this function will retrieve the data for the passed in data object
// and return a string of data.

long ll_count
string ls_data

if not isvalid(ids_data) THEN
	ids_data = create DataStore
end if


ids_data.dataobject = as_datasource


ids_data.settransobject(invo_transaction)

ll_count = ids_data.retrieve()

ls_data = ids_data.describe("datawindow.data")

return ls_data

end function

public function integer of_get_all_saleorders_id (ref long al_id[]);//
// get all the sales orders ids
//

long ll_row_count
int li_i


ll_row_count = ids_sales_order.rowcount()

if ll_row_count <= 0 THEN
	ll_row_count = of_retrieve_sales()
	if ll_row_count <= 0 THEN
		return 0
	end if
	
end if

al_id = ids_sales_order.object.id.primary

return ll_row_count



end function

public function integer of_get_all_saleorders_id (date adt_date, integer ai_direction, ref long al_id[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_get_all_salesorders_id
//
//	Access:  public
//
//	Arguments:
//	adt_date - date used to filter for ai_direction
// ai_direction - direction to filter; -1=before adt_date, 1=after adt_date
// al_id - array to pass back sales order ids
//
//	Returns:  int
//         the number of rows in the array
//
//	Description:
// gets all the sales orders ids data  before or after passed in date 
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	5.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
//	Copyright © 1996 Powersoft Corporation.  All Rights Reserved.
//
//////////////////////////////////////////////////////////////////////////////
//
// get all the sales orders ids
//
string ls_filter
long ll_row_count
int li_i, li_rc


// make sure all the data is in the primary buffer
ids_sales_order.setfilter("")
ids_sales_order.filter()


ll_row_count = ids_sales_order.rowcount()

if ll_row_count <= 0 THEN
	ll_row_count = of_retrieve_sales()
	if ll_row_count <= 0 THEN
		return 0
	end if
	
end if

// make sure all the data is in the primary buffer
ids_sales_order.setfilter("")
ids_sales_order.filter()


// filter datastore
if ai_direction = -1 THEN
		ls_filter = "order_date <= date("+"'"+string(adt_date)+"'"+")"
	else
		ls_filter = "order_date >= date("+"'"+string(adt_date)+"'"+")"
end if
	
li_rc = ids_sales_order.setfilter(ls_filter)	
li_rc = ids_sales_order.filter()

ll_row_count = ids_sales_order.rowcount()

if NOT ll_row_count > 0 THEN
	return ll_row_count
end if


al_id = ids_sales_order.object.id.primary

return ll_row_count



end function

public function string of_get_syntax (string as_datasource);// this function returns the sql select for the passed in datawindow
string ls_sql
string ls_dwsyntax

ls_dwsyntax = LibraryExport (is_reportfile, as_datasource, exportdatawindow!)

return ls_dwsyntax

end function

public function integer of_get_report_list (ref string as_datasource[], ref string as_comment[]);// this function is called to get the current list of reports available 
// from the report pbl

string ls_objects
int    li_count, li_i

// get a list of the datawindows in the reports PBL
	ls_objects = LibraryDirectory ( is_reportfile, dirdatawindow!)
		
	if ls_objects <> "" THEN
		li_count = ids_lib_list.importstring(ls_objects)
	end if
	
// pass the comments from the primary buffer to the array	
as_comment = ids_lib_list.object.comments.primary
as_datasource = ids_lib_list.object.name.primary



return li_count

end function

on uo_sales_order.create
TriggerEvent( this, "constructor" )
end on

on uo_sales_order.destroy
TriggerEvent( this, "destructor" )
end on

event constructor;call super::constructor;// create and set up datastore objects to use in this object
ids_product = create DataStore
ids_sales_order = create DataStore
ids_customer = create DataStore
ids_employees = create DataStore
ids_lib_list = create DataStore
ids_sales_order_item = create DataStore

ids_product.dataobject = "d_product"
ids_sales_order.dataobject = "d_sales_order"
ids_customer.dataobject = "d_customer"
ids_employees.dataobject = "d_employee"
ids_lib_list.dataobject = "d_lib_string"
ids_sales_order_item.dataobject = "d_sales_item"
end event

