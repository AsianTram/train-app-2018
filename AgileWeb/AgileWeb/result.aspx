<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="result.aspx.cs" Inherits="AgileWeb.result" ValidateRequest="false" %>

<!DOCTYPE html>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Xml" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8"/>
        <link rel="stylesheet" href="style.css"/>
        <link href="https://fonts.googleapis.com/css?family=Poiret+One" rel="stylesheet"/>
        <title>Train Data</title>
</head>
<body>
    <form id="form1" runat="server">
        <header><img src="train.png">Train Data</header>
    <div id="wrapper">
        <table>
            <tr>
                <th>Date</th>
                <th>Station</th>
                <th>Train</th>
                <th>Track</th>
                <th>Estimated time</th>
                <th>Destination</th>
				<th>Status</th>
            </tr>
			<%
				// Extract part
				StringWriter writer = new StringWriter();
				WebRequest request = WebRequest.Create(@"https://rata.digitraffic.fi/api/v1/live-trains/station/HKI?minutes_before_departure=15&minutes_after_departure=15&minutes_before_arrival=15&minutes_after_arrival=15");
				WebResponse response = request.GetResponse();
				Stream datastream = response.GetResponseStream();
				StreamReader streamReader = new StreamReader(datastream);
				string responseFromServer = streamReader.ReadToEnd();
				string [] firstcut = responseFromServer.Split('{');
				List<string> trainList = new List<string>();
				int j = 0;
				trainList.Add("");
				for(int i =0; i< firstcut.Length; i++)
				{

					if(firstcut[i].Contains("trainNumber")==false)
					{
						trainList[j] += firstcut[i];
					}
					else
					{
						trainList.Add("");
						j++;
						trainList[j] += firstcut[i];
					}

				}
				List<string> trainExtract = new List<string>();
				int count = 0;
				for (int i = 1; i < trainList.Count; i++)
				{
					string traininfo = trainList[i];
					int inde1 = traininfo.IndexOf("trainNumber") + 13;
					int space = traininfo.IndexOf(",\"departure")-inde1;
					trainExtract.Add(traininfo.Substring(inde1, space));
					string[] seperate = traininfo.Split('}');
					for (int k = 0; k < seperate.Length; k++)
					{
						if (seperate[k].Contains("trainStopping\":true") && seperate[k].Contains("DEPARTURE"))
						{
							int inde2 = seperate[k].IndexOf("stationShortCode") + 19;
							int space2 = seperate[k].IndexOf(",", inde2) - 1 - inde2;
							string route = seperate[k].Substring(inde2, space2);
							int inde3 = seperate[k].IndexOf("Track") + 8;
							int space3 = seperate[k].IndexOf(",", inde3) - 1 - inde3;
							string trackInfo = seperate[k].Substring(inde3, space3);
							int inde4 = seperate[k].IndexOf("scheduledTime") + 16;
							int space4 = seperate[k].IndexOf("T", inde4) - inde4;
							string dayInfo = seperate[k].Substring(inde4, space4);
							int inde5 = seperate[k].IndexOf("T", inde4) + 1;
							int space5 = seperate[k].IndexOf("Z", inde5) - inde5;
							string timeInfo = seperate[k].Substring(inde5, space5);
							string cancel = "";
							int inde6 = seperate[k].IndexOf("trainStopping") + 15;
							int space6 = seperate[k].IndexOf(",", inde6) - inde6;
							string stopping = seperate[k].Substring(inde6, space6);
							if (seperate[k].Contains("cancelled\":false"))
							{
								cancel = "not canceled";
							}
							else
							{
								cancel = "canceled";
							}
							trainExtract[count] += "/" + route + ";" + trackInfo + ";" + dayInfo + ";" + timeInfo + ";" + cancel+";"+ stopping;
						}
					}
					count++;
				}


				// Start to edit the output from here
				int min = int.Parse(Request.Form["minute"]);
				int hou = int.Parse(Request.Form["hour"]);
				//int date = int.Parse(Request.Form["day"]);
				//int mon = int.Parse(Request.Form["month"]);
				//string monstring = "";
				//string dastring = "";
				string houstring = "";
				string minstring = "";
				/*
				if (mon < 10)
				{
					monstring = "0" + mon.ToString();
				}
				else
					monstring = mon.ToString();
				if (date < 10)
					dastring = "0" + date.ToString();
				else
					dastring = date.ToString();
					*/
				if (hou < 10)
					houstring = "0" + hou.ToString();
				else
					houstring = hou.ToString();
				if (min < 10)
					minstring = "0" + min.ToString();
				else
					minstring = min.ToString();

				//DateTime userdate = DateTime.ParseExact(DateTime.Now.Year.ToString() + "-" + monstring + "-" + dastring, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture);
				DateTime currentday = DateTime.ParseExact(DateTime.Today.Year+"-"+twodigits((int)(DateTime.Today.Month))+"-"+twodigits((int)DateTime.Today.Day),"yyyy-MM-dd",System.Globalization.CultureInfo.InvariantCulture);
				DateTime usertime = DateTime.ParseExact(houstring + ":" + minstring + ":00.000", "HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture);
				//DateTime userdatetime = DateTime.ParseExact(userdate.ToString() + " " + usertime.ToString(), "yyyy-MM-dd HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture);
				DateTime timewithdura = new DateTime();
				DateTime datewithdura = new DateTime();
				//DateTime datetimewithdura = new DateTime();
				if (int.TryParse(Request.Form["duration"], out int dur))
				{
					int houplus = hou + dur;
					int dateplus = DateTime.Today.Day;
					int monthplus = DateTime.Today.Month;
					while(houplus >= 24)
					{

						if (houplus >= 24)
						{
							houplus -= 24;
							dateplus++;


						}
						if (monthplus == 2 && dateplus > 28)
						{
							monthplus++;
							dateplus -= 28;
						}
						else if (monthplus % 2 == 0 && monthplus < 12 && monthplus != 2 && dateplus > 30)
						{
							monthplus++;
							dateplus -= 30;
						}
						else if (monthplus % 2 == 1 && monthplus < 12 && dateplus > 31)
						{
							monthplus++;
							dateplus -= 31;
						}
						else if (monthplus == 12 && dateplus > 31)
						{
							monthplus = 1;
							dateplus -= 31;
						}


					}
					string houplusstr = houplus.ToString();
					if (houplus < 10)
						houplusstr = "0" + houplus.ToString();
					string dateplusstr = dateplus.ToString();
					if (dateplus < 10)
						dateplusstr = "0" + dateplus.ToString();
					string monthplusstr = monthplus.ToString();
					if (monthplus < 10)
						monthplusstr = "0" + monthplus.ToString();
					timewithdura = DateTime.ParseExact(houplusstr + ":" + minstring + ":00.000", "HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture);
					datewithdura =  DateTime.ParseExact(DateTime.Now.Year.ToString() + "-" + monthplusstr + "-" + dateplusstr, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture);
					/*
					else
					{
						string houplusstr = "";
						if (houplus < 10)
							houplusstr = "0" + houplus.ToString();
						else
							houplusstr = houplus.ToString();
						timewithdura = DateTime.ParseExact(houplusstr + ":" + minstring + ":00.000", "HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture);
						datewithdura = userdate;
					}
					*/


				}
				//datetimewithdura = DateTime.ParseExact(datewithdura.ToString() + " " + timewithdura.ToString(), "yyyy-MM-dd HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture);



				// Train station full name extract 
				List<string> fullnamestation = new List<string>();
				StringWriter stringWriter = new StringWriter();
				WebRequest request1 = WebRequest.Create(@"https://rata.digitraffic.fi/api/v1/metadata/stations");
				WebResponse response1 = request1.GetResponse();
				Stream stream = response1.GetResponseStream();
				StreamReader reader = new StreamReader(stream);
				string serverRespond = reader.ReadToEnd();
				string[] cutpart = serverRespond.Split('{');
				for (int i=1; i< cutpart.Length;i++)
				{
					int index1 = cutpart[i].IndexOf("stationName")+ 14;
					int take = cutpart[i].IndexOf("\",", index1)-index1;
					string stationName = cutpart[i].Substring(index1, take);
					int index2 = cutpart[i].IndexOf("stationShortCode")+ 19;
					int take2 = cutpart[i].IndexOf("\",", index2)-index2;
					string shortCode = cutpart[i].Substring(index2, take2);
					string element = stationName + " (" + shortCode + ")";
					fullnamestation.Add(element);

				}
				for (int i=0; i<trainExtract.Count;i++)
				{
					string[] breakdown1 = trainExtract[i].Split('/');
					string trainNum = breakdown1[0];

					for(int k=1; k<breakdown1.Length;k++)
					{
						string[] breakdown2= breakdown1[k].Split(';');
						string finalroute = breakdown1[breakdown1.Length - 1];
						string [] finalroutesplit = finalroute.Split(';');
						string destination = finalroutesplit[0];
						string timme = breakdown2[3];
						DateTime timeextract = DateTime.ParseExact(breakdown2[3], "HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture);
						DateTime dateextract = DateTime.ParseExact(breakdown2[2],  "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture);
						//DateTime datetimeextract = DateTime.ParseExact(dateextract.ToString() + " " + timeextract.ToString(), "yyyy-MM-dd HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture);
						string sth = breakdown2[0];
						string sth1 = Request.Form["Place"];
						string sth2 = breakdown2[4];
						//bool timecomp = (timeextract > usertime);

						if(currentday== datewithdura )
						{
							if(breakdown2[0]==Request.Form["Place"]&& timeextract>= usertime && timeextract<= timewithdura&&dateextract>=currentday&& dateextract<= datewithdura)
							{
								int num = 0;
								for(int l = 0; l< fullnamestation.Count; l++)
								{
									if(fullnamestation[l].Contains(destination))
									{
										num = l;
										break;
									}
								}
								string test = fullnamestation[num];
								Response.Write("<tr>");
								Response.Write("<td>" + dateextract.ToString().Substring(0,10) + "</td><td>" + Request.Form["Place"] + "</td><td>" + trainNum + "</td><td>" + breakdown2[1] + "</td><td>" + timeextract.ToString().Substring(11,8) + "</td><td>" + fullnamestation[num] + "</td><td>"+ breakdown2[4]+"</td>");
								Response.Write("</tr>");
							}
						}
						else
						{
							if(breakdown2[0]==Request.Form["Place"])
							{
								if(dateextract==currentday&& timeextract>= usertime)
								{
									int num = 0;
									for(int l = 0; l< fullnamestation.Count; l++)
									{
										if(fullnamestation[l].Contains(destination))
										{
											num = l;
											break;
										}
									}
									Response.Write("<tr>");
									Response.Write("<td>" + dateextract.ToString().Substring(0,10) + "</td><td>" + Request.Form["Place"] + "</td><td>" + trainNum + "</td><td>" + breakdown2[1] + "</td><td>" + timeextract.ToString().Substring(11,8) + "</td><td>" + fullnamestation[num] + "</td><td>"+ breakdown2[4]+"</td>");
									Response.Write("</tr>");
								}

								else if(dateextract== datewithdura && timeextract<= timewithdura)
								{
									int num = 0;
									for(int l = 0; l< fullnamestation.Count; l++)
									{
										if(fullnamestation[l].Contains(destination))
										{
											num = l;
											break;
										}
									}
									Response.Write("<tr>");
									Response.Write("<td>" + dateextract.ToString().Substring(0,10) + "</td><td>" + Request.Form["Place"] + "</td><td>" + trainNum + "</td><td>" + breakdown2[1] + "</td><td>" + timeextract.ToString().Substring(11,8) + "</td><td>" + fullnamestation[num] + "</td><td>"+ breakdown2[4]+"</td>");
									Response.Write("</tr>");
								}

							}
						}

					}

				}

			%>
			<!--
            <tr>
                <td>
					<%
						//Response.Write(Request.Form["day"] + "/" + Request.Form["month"]);
					%>
                </td>
                <td>
					<%
						//Response.Write(Request.Form["Place"]);
					%>
                </td>
                <td>j456</td>
                <td>2</td>
                <td>12:30</td>
                <th>Helsinki</th>
            </tr>
            <tr>
                <td></td>
                <td>Lahti</td>
                <td>f86</td>
                <td>3</td>
                <td>15:30</td>
                <th>Mäntsälä</th>
            </tr>
            <tr>
                <td></td>
                <td>Lahti</td>
                <td>h46</td>
                <td>9</td>
                <td>17:25</td>
                <th>Kerava</th>
            </tr>
            <tr>
                <td></td>
                <td>Lahti</td>
                <td>k586</td>
                <td>7</td>
                <td>18:30</td>
                <th>Riihimäki</th>
            </tr>
            <tr>
                <td></td>
                <td>Lahti</td>
                <td>r93</td>
                <td>4</td>
                <td>20:10</td>
                <th>Tikkurila</th>
            </tr>
            <tr>
                <td></td>
                <td>Lahti</td>
                <td>i76</td>
                <td>6</td>
                <td>22:25</td>
                <th>Pasila</th>
            </tr>
			-->
        </table>
    <li><a href="Search.aspx">
            <div id="button2">
                Back
            </div>
            </a>
        </li>
    </div>
    <footer><p3>© 2018 All Rights Reserved. Use of this site constitutes acceptance of our Terms of Use and Privacy Policy.</p3></footer>
    </form>
</body>
</html>
