<%@ Page Language="C#" Inherits="CrownPeak.Internal.Debug.OutputInit" %>
<%@ Import Namespace="CrownPeak.CMSAPI" %>
<%@ Import Namespace="CrownPeak.CMSAPI.Services" %>
<%@ Import Namespace="CrownPeak.CMSAPI.CustomLibrary" %>
<!--DO NOT MODIFY CODE ABOVE THIS LINE-->
<%//This plugin uses OutputContext as its context class type%>
<%
	// output.aspx: template file to specify the published content in site HTML
	// if no preview.aspx exists, then this is used by default for preview
	if (asset.Raw["save"] == "replace" || asset.Raw["save"] == "report")
	{
		Out.WriteLine("Script Running");
	}
	else
	{
%>
<!DOCTYPE html>
<html>
<head>
	<title>String Replacement Report</title>
	<style>
		.CSSTableGenerator {
			margin: 0px;
			padding: 0px;
			width: 100%;
			border: 1px solid #000000;
			-moz-border-radius-bottomleft: 0px;
			-webkit-border-bottom-left-radius: 0px;
			border-bottom-left-radius: 0px;
			-moz-border-radius-bottomright: 0px;
			-webkit-border-bottom-right-radius: 0px;
			border-bottom-right-radius: 0px;
			-moz-border-radius-topright: 0px;
			-webkit-border-top-right-radius: 0px;
			border-top-right-radius: 0px;
			-moz-border-radius-topleft: 0px;
			-webkit-border-top-left-radius: 0px;
			border-top-left-radius: 0px;
		}

			.CSSTableGenerator table {
				border-collapse: collapse;
				border-spacing: 0;
				width: 100%;
				height: 100%;
				margin: 0px;
				padding: 0px;
			}

			.CSSTableGenerator tr:last-child td:last-child {
				-moz-border-radius-bottomright: 0px;
				-webkit-border-bottom-right-radius: 0px;
				border-bottom-right-radius: 0px;
			}

			.CSSTableGenerator table tr:first-child td:first-child {
				-moz-border-radius-topleft: 0px;
				-webkit-border-top-left-radius: 0px;
				border-top-left-radius: 0px;
			}

			.CSSTableGenerator table tr:first-child td:last-child {
				-moz-border-radius-topright: 0px;
				-webkit-border-top-right-radius: 0px;
				border-top-right-radius: 0px;
			}

			.CSSTableGenerator tr:last-child td:first-child {
				-moz-border-radius-bottomleft: 0px;
				-webkit-border-bottom-left-radius: 0px;
				border-bottom-left-radius: 0px;
			}

			.CSSTableGenerator tr:hover td {
				background-color: #ffffff; /*#cccc99;*/
			}

			.CSSTableGenerator td {
				vertical-align: middle;
				background-color: #cccccc;
				border: 1px solid #000000;
				border-width: 0px 1px 1px 0px;
				text-align: left;
				padding: 10px;
				font-size: 12px;
				font-family: Arial;
				font-weight: normal;
				color: #000000;
			}

			.CSSTableGenerator tr:last-child td {
				border-width: 0px 1px 0px 0px;
			}

			.CSSTableGenerator tr td:last-child {
				border-width: 0px 0px 1px 0px;
			}

			.CSSTableGenerator tr:last-child td:last-child {
				border-width: 0px 0px 0px 0px;
			}

			.CSSTableGenerator tr:first-child td {
				background: -o-linear-gradient(bottom, #003366 5%, #003f7f 100%);
				background: -webkit-gradient( linear, left top, left bottom, color-stop(0.05, #003366), color-stop(1, #003f7f) );
				background: -moz-linear-gradient( center top, #003366 5%, #003f7f 100% );
				filter: progid:DXImageTransform.Microsoft.gradient(startColorstr="#003366", endColorstr="#003f7f");
				background: -o-linear-gradient(top,#003366,003f7f);
				background-color: #003366;
				border: 0px solid #000000;
				text-align: center;
				border-width: 0px 0px 1px 1px;
				font-size: 15px;
				font-family: Arial;
				font-weight: bold;
				color: #ffffff;
			}

			.CSSTableGenerator tr:first-child:hover td {
				background: -o-linear-gradient(bottom, #003366 5%, #003f7f 100%);
				background: -webkit-gradient( linear, left top, left bottom, color-stop(0.05, #003366), color-stop(1, #003f7f) );
				background: -moz-linear-gradient( center top, #003366 5%, #003f7f 100% );
				filter: progid:DXImageTransform.Microsoft.gradient(startColorstr="#003366", endColorstr="#003f7f");
				background: -o-linear-gradient(top,#003366,003f7f);
				background-color: #003366;
			}

			.CSSTableGenerator tr:first-child td:first-child {
				border-width: 0px 0px 1px 0px;
			}

			.CSSTableGenerator tr:first-child td:last-child {
				border-width: 0px 0px 1px 1px;
			}

		.asset-info {
			background-color: #242424 !important;
			color: #ffffff !important;
			font-weight: bold !important;
			margin: 5px 0;
		}

		.asset-value {
			background-color: #ffe243 !important;
			font-weight: bold !important;
		}
	</style>
</head>
<body>
	<div class="CSSTableGenerator">
		<table>
			<tr>
				<td colspan="3">String Replacement Report</td>
			</tr>
			<% Out.WriteLine(asset.Raw["log"]); %>
		</table>
	</div>
</body>
</html>
<%  } %>