<%@ Page Language="C#" Inherits="CrownPeak.Internal.Debug.InputInit" %>
<%@ Import Namespace="CrownPeak.CMSAPI" %>
<%@ Import Namespace="CrownPeak.CMSAPI.Services" %>
<%@ Import Namespace="CrownPeak.CMSAPI.CustomLibrary" %>
<!--DO NOT MODIFY CODE ABOVE THIS LINE-->
<%//This plugin uses InputContext as its context class type%>
<%
	Dictionary<string, string> dicWorkflows = new Dictionary<string, string>();
	dicWorkflows.Add("All", "");
	dicWorkflows.Add("Draft", "Draft");
	dicWorkflows.Add("Dev", "Dev");
	dicWorkflows.Add("QA", "QA");
	dicWorkflows.Add("Stage", "Stage");
	dicWorkflows.Add("Legal Review", "Legal Review");
	dicWorkflows.Add("Live", "Live");

	Dictionary<string, string> dicSaveOption = new Dictionary<string, string>();
	dicSaveOption.Add("None", "no");
	dicSaveOption.Add("Only Run Report", "report");
	dicSaveOption.Add("Replace", "replace");

	Input.StartTabbedPanel("String Replace Setup");
	{
		Input.ShowMessage("Please use with caution", MessageType.Warning);
		Input.StartHorizontalWrapContainer();
		Input.ShowTextBox("Current Text", "old_text", helpMessage: "Text to search. Case sensitive");
		Input.ShowTextBox("New Text", "new_text", helpMessage: "Text to replace with. Case sensitive");
		Input.EndHorizontalWrapContainer();

		while (Input.NextPanel("folder_panel", displayName: "Folder List"))
		{
			Input.StartHorizontalWrapContainer();
			Input.ShowSelectFolder("Folder To Crawl", "folder");
			Input.ShowDropDown("Workflow Status", "folder_workflow", dicWorkflows, Util.MakeList(""));
			Input.ShowCheckBox("", "subfolder_include", "true", "Include Subfolders", unCheckedValue: "false", defaultChecked: false);
			Input.EndHorizontalWrapContainer();
		}

		while (Input.NextPanel("exclude_key_panel", displayName: "List of CMS fields to Exclude"))
		{
			Input.ShowTextBox("Field name", "exclude_key", helpMessage: "It's not necessary to enter full field name to exclude.");
		}

		Input.StartControlPanel("Save");
		{
			Input.ShowMessage("To replace the string select \"Replace\" option", MessageType.Warning);
			Input.ShowMessage("Select \"Only Run Report\" if you just want to see the report");
			Input.ShowDropDown("Save Option", "save", dicSaveOption, Util.MakeList("no"));
		}
		Input.EndControlPanel();
	}
	Input.EndTabbedPanel();
%>