<!--#include file="header.asp" --> 
<%
if (Session("MM_UserID") = "") then
	Response.Redirect("index.asp")
end if

' *** Delete Record: construct a sql delete statement and execute it

Dim rsListOrder
Dim rsListOrder_cmd
Dim rsListOrder_numRows
Dim querylistproductPlus
Dim brandNameQuery
Dim inventoryQuery
Dim status
Dim statusOK
status = HTMLEncode(Request.QueryString("status"))

if (Request.QueryString <> "") then
	
	if Request.QueryString("status") <> "" then
		if Request.QueryString("status") <> "" then
			statusOK = " status = '"&brandNameQuery&"' "
		end if
		querylistproductPlus = " and status = "&statusOK
	else 
		querylistproductPlus = ""

	end if
end if
Set rsListOrder_cmd = Server.CreateObject ("ADODB.Command")
rsListOrder_cmd.ActiveConnection = MM_Connect_STRING
rsListOrder_cmd.CommandText = "SELECT * FROM dbo.tb_order where userID = "&Session("MM_UserID")&" "&querylistproductPlus&" ORDER BY dateOrder DESC"
rsListOrder_cmd.Prepared = true

Set rsListOrder = rsListOrder_cmd.Execute
rsListOrder_numRows = 0
%>
<!-- tao  dynamic table -->
<%
Dim Repeat1__numRows
Dim Repeat1__index

Repeat1__numRows = 10
Repeat1__index = 0
rsListOrder_numRows = rsListOrder_numRows + Repeat1__numRows
%>
<%
'  *** Recordset Stats, Move To Record, and Go To Record: declare stats variables

Dim rsListOrder_total
Dim rsListOrder_first
Dim rsListOrder_last

' set the record count
rsListOrder_total = rsListOrder.RecordCount

' set the number of rows displayed on this page
If (rsListOrder_numRows < 0) Then
  rsListOrder_numRows = rsListOrder_total
Elseif (rsListOrder_numRows = 0) Then
  rsListOrder_numRows = 1
End If

' set the first and last displayed record
rsListOrder_first = 1
rsListOrder_last  = rsListOrder_first + rsListOrder_numRows - 1

' if we have the correct record count, check the other stats
If (rsListOrder_total <> -1) Then
  If (rsListOrder_first > rsListOrder_total) Then
    rsListOrder_first = rsListOrder_total
  End If
  If (rsListOrder_last > rsListOrder_total) Then
    rsListOrder_last = rsListOrder_total
  End If
  If (rsListOrder_numRows > rsListOrder_total) Then
    rsListOrder_numRows = rsListOrder_total
  End If
End If
%>
<!-- xoa-->
<%
Dim MM_paramName 
%>
<%
' *** Move To Record and Go To Record: declare variables

Dim MM_rs
Dim MM_rsCount
Dim MM_size
Dim MM_uniqueCol
Dim MM_offset
Dim MM_atTotal
Dim MM_paramIsDefined

Dim MM_param
Dim MM_index

Set MM_rs    = rsListOrder
MM_rsCount   = rsListOrder_total
MM_size      = rsListOrder_numRows
MM_uniqueCol = ""
MM_paramName = ""
MM_offset = 0
MM_atTotal = false
MM_paramIsDefined = false
If (MM_paramName <> "") Then
  MM_paramIsDefined = (Request.QueryString(MM_paramName) <> "")
End If
%>
<%
' *** Move To Record: handle 'index' or 'offset' parameter

if (Not MM_paramIsDefined And MM_rsCount <> 0) then

  ' use index parameter if defined, otherwise use offset parameter
  MM_param = Request.QueryString("index")
  If (MM_param = "") Then
    MM_param = Request.QueryString("offset")
  End If
  If (MM_param <> "") Then
    MM_offset = Int(MM_param)
  End If

  ' if we have a record count, check if we are past the end of the recordset
  If (MM_rsCount <> -1) Then
    If (MM_offset >= MM_rsCount Or MM_offset = -1) Then  ' past end or move last
      If ((MM_rsCount Mod MM_size) > 0) Then         ' last page not a full repeat region
        MM_offset = MM_rsCount - (MM_rsCount Mod MM_size)
      Else
        MM_offset = MM_rsCount - MM_size
      End If
    End If
  End If

  ' move the cursor to the selected record
  MM_index = 0
  While ((Not MM_rs.EOF) And (MM_index < MM_offset Or MM_offset = -1))
    MM_rs.MoveNext
    MM_index = MM_index + 1
  Wend
  If (MM_rs.EOF) Then 
    MM_offset = MM_index  ' set MM_offset to the last possible record
  End If

End If
%>
<%
' *** Move To Record: if we dont know the record count, check the display range

If (MM_rsCount = -1) Then

  ' walk to the end of the display range for this page
  MM_index = MM_offset
  While (Not MM_rs.EOF And (MM_size < 0 Or MM_index < MM_offset + MM_size))
    MM_rs.MoveNext
    MM_index = MM_index + 1
  Wend

  ' if we walked off the end of the recordset, set MM_rsCount and MM_size
  If (MM_rs.EOF) Then
    MM_rsCount = MM_index
    If (MM_size < 0 Or MM_size > MM_rsCount) Then
      MM_size = MM_rsCount
    End If
  End If

  ' if we walked off the end, set the offset based on page size
  If (MM_rs.EOF And Not MM_paramIsDefined) Then
    If (MM_offset > MM_rsCount - MM_size Or MM_offset = -1) Then
      If ((MM_rsCount Mod MM_size) > 0) Then
        MM_offset = MM_rsCount - (MM_rsCount Mod MM_size)
      Else
        MM_offset = MM_rsCount - MM_size
      End If
    End If
  End If

  ' reset the cursor to the beginning
  If (MM_rs.CursorType > 0) Then
    MM_rs.MoveFirst
  Else
    MM_rs.Requery
  End If

  ' move the cursor to the selected record
  MM_index = 0
  While (Not MM_rs.EOF And MM_index < MM_offset)
    MM_rs.MoveNext
    MM_index = MM_index + 1
  Wend
End If
%>
<%
' *** Move To Record: update recordset stats

' set the first and last displayed record
rsListOrder_first = MM_offset + 1
rsListOrder_last  = MM_offset + MM_size

If (MM_rsCount <> -1) Then
  If (rsListOrder_first > MM_rsCount) Then
    rsListOrder_first = MM_rsCount
  End If
  If (rsListOrder_last > MM_rsCount) Then
    rsListOrder_last = MM_rsCount
  End If
End If

' set the boolean used by hide region to check if we are on the last record
MM_atTotal = (MM_rsCount <> -1 And MM_offset + MM_size >= MM_rsCount)
%>
<%
' *** Go To Record and Move To Record: create strings for maintaining URL and Form parameters

Dim MM_keepNone
Dim MM_keepURL
Dim MM_keepForm
Dim MM_keepBoth

Dim MM_removeList
Dim MM_item
Dim MM_nextItem

' create the list of parameters which should not be maintained
MM_removeList = "&index="
If (MM_paramName <> "") Then
  MM_removeList = MM_removeList & "&" & MM_paramName & "="
End If

MM_keepURL=""
MM_keepForm=""
MM_keepBoth=""
MM_keepNone=""

' add the URL parameters to the MM_keepURL string
For Each MM_item In Request.QueryString
  MM_nextItem = "&" & MM_item & "="
  If (InStr(1,MM_removeList,MM_nextItem,1) = 0) Then
    MM_keepURL = MM_keepURL & MM_nextItem & Server.URLencode(Request.QueryString(MM_item))
  End If
Next

' add the Form variables to the MM_keepForm string
For Each MM_item In Request.Form
  MM_nextItem = "&" & MM_item & "="
  If (InStr(1,MM_removeList,MM_nextItem,1) = 0) Then
    MM_keepForm = MM_keepForm & MM_nextItem & Server.URLencode(Request.Form(MM_item))
  End If
Next

' create the Form + URL string and remove the intial '&' from each of the strings
MM_keepBoth = MM_keepURL & MM_keepForm
If (MM_keepBoth <> "") Then 
  MM_keepBoth = Right(MM_keepBoth, Len(MM_keepBoth) - 1)
End If
If (MM_keepURL <> "")  Then
  MM_keepURL  = Right(MM_keepURL, Len(MM_keepURL) - 1)
End If
If (MM_keepForm <> "") Then
  MM_keepForm = Right(MM_keepForm, Len(MM_keepForm) - 1)
End If

' a utility function used for adding additional parameters to these strings
Function MM_joinChar(firstItem)
  If (firstItem <> "") Then
    MM_joinChar = "&"
  Else
    MM_joinChar = ""
  End If
End Function
%>
<%
' *** Move To Record: set the strings for the first, last, next, and previous links

Dim MM_keepMove
Dim MM_moveParam
Dim MM_moveFirst
Dim MM_moveLast
Dim MM_moveNext
Dim MM_movePrev

Dim MM_urlStr
Dim MM_paramList
Dim MM_paramIndex
Dim MM_nextParam

MM_keepMove = MM_keepBoth
MM_moveParam = "index"

' if the page has a repeated region, remove 'offset' from the maintained parameters
If (MM_size > 1) Then
  MM_moveParam = "offset"
  If (MM_keepMove <> "") Then
    MM_paramList = Split(MM_keepMove, "&")
    MM_keepMove = ""
    For MM_paramIndex = 0 To UBound(MM_paramList)
      MM_nextParam = Left(MM_paramList(MM_paramIndex), InStr(MM_paramList(MM_paramIndex),"=") - 1)
      If (StrComp(MM_nextParam,MM_moveParam,1) <> 0) Then
        MM_keepMove = MM_keepMove & "&" & MM_paramList(MM_paramIndex)
      End If
    Next
    If (MM_keepMove <> "") Then
      MM_keepMove = Right(MM_keepMove, Len(MM_keepMove) - 1)
    End If
  End If
End If

' set the strings for the move to links
If (MM_keepMove <> "") Then 
  MM_keepMove = HTMLEncode(MM_keepMove) & "&"
End If

MM_urlStr = Request.ServerVariables("URL") & "?" & MM_keepMove & MM_moveParam & "="

MM_moveFirst = MM_urlStr & "0"
MM_moveLast  = MM_urlStr & "-1"
MM_moveNext  = MM_urlStr & CStr(MM_offset + MM_size)
If (MM_offset - MM_size < 0) Then
  MM_movePrev = MM_urlStr & "0"
Else
  MM_movePrev = MM_urlStr & CStr(MM_offset - MM_size)
End If
%>

<section class="content container">


          <div class="box">
            <div class="box-header">
            <!-- /.box-header -->
            <h1>Danh sách đơn hàng</h1>
			<% if (Session("statusDelproduct")<> "") then
				Response.Write("<p class=""alert alert-success"">"&Session.Contents("statusDelproduct")&"</p>")
				Session.Contents.Remove("statusDelproduct")
			end if%>
			</div>
			<div class="box-body table-responsive">
                  <table class="table table-hover">
					<thead>
                      <tr>
                        <th>Tên người nhận</th>
                        <th>Email người nhận</th>
                        <th>Số điện thoại người nhận</th>
                        <th>Ngày gửi đơn hàng</th>
                        <th>Tình trạng</th>
                        <th>Tác vụ</th>
                      </tr>
					</thead>
                    <tbody>
                        <% While ((Repeat1__numRows <> 0) AND (NOT rsListOrder.EOF)) %>
						<%
							Dim statusorder
							statusorder = (rsListOrder.Fields.Item("status")).Value
							if statusorder = "True" then
								statusorder = "Đã xử lý"
							else
								statusorder = "Chưa xử lý"
							end if
						%>
                      <tr>
                        <td><%=(rsListOrder.Fields.Item("nameRecipient").Value)%></td>
                        <td><%=(rsListOrder.Fields.Item("emailRecipient").Value)%></td>
                        <td><%=(rsListOrder.Fields.Item("phoneRecipient").Value)%></td>
                        <td><%=(rsListOrder.Fields.Item("dateOrder").Value)%></td>
                        <td><%=statusorder%></td>
                        <td>
						<button data-toggle="modal" data-target="#orderID-<%=(rsListOrder.Fields.Item("orderID").Value)%>" type="submit" class="btn btn-primary" style="width: 80px;margin: 0;" >Xem</button>
						<span class="hidden"><%=(rsListOrder.Fields.Item("detail").Value)%></span>
                            <div class="modal fade" id="orderID-<%=(rsListOrder.Fields.Item("orderID").Value)%>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                              <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                  <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                                    <h4 class="modal-title" id="myModalLabel">Người nhận đơn hàng: <%=(rsListOrder.Fields.Item("nameRecipient").Value)%></h4>
                                  </div>
                                  <div class="modal-body table-responsive">
								  <div class="well">
								  Tổng giá trị đơn hàng: <%=(rsListOrder.Fields.Item("totalPrice").Value)%> VNĐ<br/>
								  Tên người nhận: <%=(rsListOrder.Fields.Item("nameRecipient").Value)%><br/>
								  Số điện thoại người nhận: <%=(rsListOrder.Fields.Item("phoneRecipient").Value)%><br/>
								  Địa chỉ: <%=(rsListOrder.Fields.Item("addressRecipient").Value)%>
								  </div>
								  <table class="table table-hover">
									<thead>
									  <tr>
										<th colspan="2">Tên sản phẩm</th>
										<th>Giá</th> 
										<th>Số lượng</th>
										<th>Tổng</th>
									  </tr>
									</thead>
									<tbody class="content-detail">
									</tbody>
								  </table>
                                  </div>
                                  <div class="modal-footer">
                                    <a href="#" class="btn btn-primary" data-dismiss="modal">Đóng</a>
                                  </div>
                                </div>
                              </div>
                            </div>
                        </td><% 
  Repeat1__index=Repeat1__index+1
  Repeat1__numRows=Repeat1__numRows-1
  rsListOrder.MoveNext()
Wend
%>
                          
                        
                    </tr>
                    </tbody>
                  </table>
               <div class="col-sm-7">
        <div class="dataTables_paginate paging_simple_numbers" id="example2_paginate">
        <ul class="pagination">
        <li class="paginate_button previous" id="example2_previous"><% If MM_offset <> 0 Then %>
        <a href="<%=MM_movePrev%>" aria-controls="example2" data-dt-idx="0" tabindex="0">Previous</a> <% End If %></li>
        <li class="paginate_button active"><% If MM_offset <> 0 Then %><a href="<%=MM_moveFirst%>" aria-controls="example2" data-dt-idx="1" tabindex="0">First</a><% End If %></li>
        <li class="paginate_button "><% If Not MM_atTotal Then %><a href="<%=MM_moveNext%>" aria-controls="example2" data-dt-idx="2" tabindex="0">Next</a><% End If %></li>
        <li class="paginate_button next" id="example2_next"><% If Not MM_atTotal Then %><a href="<%=MM_moveLast%>" aria-controls="example2" data-dt-idx="7"  tabindex="0">Last</a><% End If %></li>
        </ul>
        </div>
        </div>
              
            </div>
            <!-- /.box-body -->
          </div>
		  
          <!-- /.box -->

  </section>
<% rsListOrder.Close()
Set rsListOrder = Nothing %>


<!--#include file="footer.asp" -->
