<%@ Page Language="C#" Inherits="CrownPeak.Internal.Debug.PostSaveInit" %>
<%@ Import Namespace="CrownPeak.CMSAPI" %>
<%@ Import Namespace="CrownPeak.CMSAPI.Services" %>
<%@ Import Namespace="CrownPeak.CMSAPI.CustomLibrary" %>
<!--DO NOT MODIFY CODE ABOVE THIS LINE-->
<%//This plugin uses PostSaveContext as its context class type%>
<%
	bool needSaving = asset.Raw["save"] == "replace" ? true : false;
	Dictionary<string, string> dicContent = new Dictionary<string, string>();

	if (asset.Raw["save"] == "replace" || asset.Raw["save"] == "report")
	{ %>
<%
	Out.StartCapture();
	List<InputFolderInfo> liFoldersInfo = new List<InputFolderInfo>();
	string szOldText = asset.Raw["old_text"];
	string szNewText = asset.Raw["new_text"];

	foreach (PanelEntry peFolder in asset.GetPanels("folder_panel"))
	{
		Asset aFolder = Asset.Load(peFolder.Raw["folder"]);
		if (aFolder.IsLoaded && !string.IsNullOrWhiteSpace(szOldText) && !string.IsNullOrWhiteSpace(szNewText))
		{
			InputFolderInfo folderInfo = new InputFolderInfo();
			folderInfo.Folder = aFolder;
			folderInfo.OldValue = szOldText;
			folderInfo.NewValue = szNewText;
			folderInfo.WorkflowStatus = peFolder.Raw["folder_workflow"];
			folderInfo.IncludeSubFolder = peFolder.Raw["subfolder_include"].Equals("true") ? true : false;
			folderInfo.IncludeDeveloper = string.IsNullOrWhiteSpace(peFolder.Raw["folder_workflow"]) ? true : false;

			liFoldersInfo.Add(folderInfo);
		}
	}

	List<string> lsExcludeKeys = new List<string>();
	foreach (PanelEntry peKey in asset.GetPanels("exclude_key_panel"))
	{
		if (!string.IsNullOrWhiteSpace(peKey.Raw["exclude_key"]))
			lsExcludeKeys.Add(peKey.Raw["exclude_key"]);
	}

	if (!string.IsNullOrWhiteSpace(szOldText) && !string.IsNullOrWhiteSpace(szNewText))
	{
		StringReplacement sr = new StringReplacement(liFoldersInfo, lsExcludeKeys);
%>
<tr>
	<td colspan="3" style="font-size: 12px;">
		<% if (needSaving)
			{ %>
		<span style="color: red; font-size: 20px; font-weight: bold;">All assets have been replaced!</span><br />
		<br />
		<% }
			else
			{ %>
		<span style="font-size: 20px; font-weight: bold;">This is just a report. None of the assets have been changed. Please review the report and Select "Replace" in the "Save Option" dropdown.</span><br />
		<br />
		<% } %>
                        Total assets found: <%= sr.GetAllFiles().Count %><br />
		Total assets replaced: <%= sr.GetData().Count %><br />
		Report Date: <%= DateTime.Now %><br />
		<%
//For testing
//foreach (Asset aFile in sr.GetAllFiles())
//{
//    Out.WriteLine("{0}<br>", aFile.Id);
//}
		%>
	</td>
</tr>
<%
	foreach (ReplacedFile rf in sr.GetData())
	{
%>
<tr>
	<td class="asset-info">Asset ID: <%= rf.AssetFile.Id %></td>
	<td class="asset-info">Workflow Status: <%= rf.AssetFile.WorkflowStatus.Name %></td>
	<td class="asset-info">Asset Label: <%= rf.AssetFile.Label %></td>
</tr>
<tr>
	<td colspan="3" class="asset-info">CMS Path: <%= rf.AssetFile.AssetPath %></td>
</tr>
<tr>
	<td class="asset-value">Key</td>
	<td class="asset-value">Old Value</td>
	<td class="asset-value">New Value</td>
</tr>
<%
	foreach (ReplacedValue rv in rf.ReplacedValues)
	{
%>
<tr>
	<td><%= rv.Key %></td>
	<td><%= Util.HtmlEncode(rv.OldValue).Replace("ph_linebreak_ph", "<br>") %></td>
	<td><%= Util.HtmlEncode(rv.NewValue).Replace("ph_linebreak_ph", "<br>") %></td>
</tr>
<%
	}
%>
<%--<tr><td colspan="3" style="background-color: yellow;"></td></tr>--%>
<%
		}

		dicContent.Add("save", "no");
		dicContent.Add("log", Out.StopCapture());
		asset.SaveContent(dicContent);

		//Replace all assets
		if (needSaving)
		{
			sr.SaveChanges();
		}
	}
%>
<%  } %>
<script runat="server" data-cpcode="true">
	public class StringReplacement
	{
		private List<ReplacedFile> lrReplacedFiles = new List<ReplacedFile>();
		private Asset aSelectedFolder;
		private List<Asset> laFilesFound;
		private List<Asset> laTotalAssets = new List<Asset>();
		private List<string> lsExcludeKeyList = new List<string>();

		public StringReplacement(List<InputFolderInfo> inputFolderInfo, List<string> excludeKeyList = null)
		{
			if (excludeKeyList != null)
				lsExcludeKeyList = excludeKeyList;

			foreach (InputFolderInfo folderInfo in inputFolderInfo)
			{
				if (folderInfo.Folder.Type.Equals(AssetType.Folder))
				{
					laFilesFound = GetFileList(folderInfo).OrderBy(a => a.AssetPath.ToString()).ToList();
					FindAndReplace(laFilesFound, folderInfo.OldValue, folderInfo.NewValue);

					laTotalAssets = laTotalAssets.Concat(laFilesFound).ToList();
				}
			}
		}

		public List<ReplacedFile> GetData()
		{
			return lrReplacedFiles;
		}

		public List<Asset> GetFilesAffected()
		{
			return lrReplacedFiles.Select(d => d.AssetFile).ToList();
		}

		public void SaveChanges()
		{
			foreach (ReplacedFile rf in lrReplacedFiles)
			{
				rf.AssetFile.SaveContent(rf.Content);
			}
		}

		public List<Asset> GetAllFiles()
		{
			return laTotalAssets;
		}

		private List<Asset> GetFileList(InputFolderInfo folderInfo)
		{
			if (folderInfo.Folder.Type.Equals(AssetType.Folder))
			{
				if (folderInfo.IncludeSubFolder)
				{
					FilterParams fpFiles = new FilterParams();
					fpFiles.Add(Comparison.Equals, AssetType.File);
					fpFiles.Add(AssetPropertyNames.TemplateId, Comparison.NotEquals, 0);

					if (string.IsNullOrWhiteSpace(folderInfo.WorkflowStatus))
						fpFiles.ExcludeFilterStatus = Util.MakeList("Retired", "Archived");
					else
						fpFiles.SetFilterStatus(folderInfo.WorkflowStatus);

					if (folderInfo.IncludeDeveloper)
						fpFiles.ExcludeProjectTypes = false;

					return folderInfo.Folder.GetFilterList(fpFiles);
				}
				else
				{

					AssetParams apFiles = new AssetParams();

					if (string.IsNullOrWhiteSpace(folderInfo.WorkflowStatus))
						apFiles.ExcludeFilterStatus = Util.MakeList("Retired", "Archived");
					else
						apFiles.SetFilterStatus(folderInfo.WorkflowStatus);

					if (folderInfo.IncludeDeveloper)
						apFiles.ExcludeProjectTypes = false;

					return folderInfo.Folder.GetFileList(apFiles);
				}
			}
			else
				return new List<Asset>();
		}

		private void FindAndReplace(List<Asset> fileList, string oldText, string newText)
		{
			ReplacedFile rf;

			foreach (Asset aFile in fileList)
			{
				if (aFile.Type.Equals(AssetType.File))
				{
					if (ReplaceContents(aFile, oldText, newText, out rf))
					{
						lrReplacedFiles.Add(rf);
					}
				}
			}
		}

		private bool ReplaceContents(Asset asset, string oldText, string newText, out ReplacedFile replacedFile)
		{
			Dictionary<string, string> dicNewContents = new Dictionary<string, string>();
			replacedFile = new ReplacedFile();
			bool isChanged = false;

			foreach (KeyValuePair<string, string> kvpField in asset.GetContent())
			{
				bool bExclude = false;
				foreach (string key in lsExcludeKeyList)
				{
					if (kvpField.Key.Contains(key))
					{
						bExclude = true;
						break;
					}
				}

				if (!bExclude && !kvpField.Key.Contains("upload#") && !kvpField.Key.Contains("upload_name#") && kvpField.Value.Contains(oldText))
				{
					isChanged = true;

					string szMatchedValue = string.Empty;
					foreach (Match match in Regex.Matches(kvpField.Value, oldText))
					{
						if (match.Index > 10)
							szMatchedValue += ".....";

						try
						{
							if (match.Index > 10)
							{
								szMatchedValue += kvpField.Value.Substring(match.Index - 10, 50) + "..... ph_linebreak_ph";
							}
							else
							{
								szMatchedValue += kvpField.Value.Substring(0, 50) + "..... ph_linebreak_ph";
							}
						}
						catch (Exception e)
						{
							szMatchedValue += kvpField.Value.Substring(match.Index);
						}
					}

					ReplacedValue rv = new ReplacedValue();
					rv.Key = kvpField.Key;
					rv.OldValue = szMatchedValue;
					rv.NewValue = szMatchedValue.Replace(oldText, newText);
					replacedFile.ReplacedValues.Add(rv);
					//rv.OldValue = kvpField.Value;
					//rv.NewValue = kvpField.Value.Replace(oldText, newText);

					dicNewContents.Add(kvpField.Key, kvpField.Value.Replace(oldText, newText));
				}
			}

			if (isChanged)
			{
				replacedFile.Content = dicNewContents;
				replacedFile.AssetFile = asset;
			}

			return isChanged;
		}
	}

	public class ReplacedFile
	{
		private List<ReplacedValue> rvList = new List<ReplacedValue>();
		private Dictionary<string, string> content = new Dictionary<string, string>();

		public Asset AssetFile { get; set; }
		public List<ReplacedValue> ReplacedValues
		{
			get { return rvList; }
			set { rvList = value; }
		}
		public Dictionary<string, string> Content
		{
			get { return content; }
			set { content = value; }
		}
	}

	public class ReplacedValue
	{
		public string Key { get; set; }
		public string OldValue { get; set; }
		public string NewValue { get; set; }
		public string OldValuePartial { get; set; }
		public string NewValuePartial { get; set; }
	}

	public class InputFolderInfo
	{
		public Asset Folder { get; set; }
		public string OldValue { get; set; }
		public string NewValue { get; set; }
		public bool IncludeSubFolder { get; set; }
		public bool IncludeDeveloper { get; set; }
		public string WorkflowStatus { get; set; }
	}
</script>