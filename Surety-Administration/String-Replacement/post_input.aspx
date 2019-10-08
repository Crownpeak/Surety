<%@ Page Language="C#" Inherits="CrownPeak.Internal.Debug.PostInputInit" %>
<%@ Import Namespace="CrownPeak.CMSAPI" %>
<%@ Import Namespace="CrownPeak.CMSAPI.Services" %>
<%@ Import Namespace="CrownPeak.CMSAPI.CustomLibrary" %>
<!--DO NOT MODIFY CODE ABOVE THIS LINE-->
<%//This plugin uses PostInputContext as its context class type%>
<%
	if (string.IsNullOrWhiteSpace(context.InputForm["old_text"]))
	{
		context.ValidationErrorFields.Add("old_text", "Please enter text");
	}

	if (string.IsNullOrWhiteSpace(context.InputForm["new_text"]))
	{
		context.ValidationErrorFields.Add("new_text", "Please enter text");
	}
%>