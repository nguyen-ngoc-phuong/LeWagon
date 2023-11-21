<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:user="http://www.ni.com/TestStand" xmlns:vb_user="http://www.ni.com/TestStand/" id="TS16.1.0">

<!--This alias is added so that the html output does not contain these namespaces. The omit-xml-declaration attribute of xsl:output element did not prevent the addition of these namespaces to the html output-->
	<xsl:namespace-alias stylesheet-prefix="xsl" result-prefix="#default"/>
	<xsl:namespace-alias stylesheet-prefix="msxsl" result-prefix="#default"/>
	<xsl:namespace-alias stylesheet-prefix="user" result-prefix="#default"/>
	<xsl:namespace-alias stylesheet-prefix="vb_user" result-prefix="#default"/>

	<msxsl:script language="vbscript" implements-prefix="vb_user">
		option explicit
		'This function will return the localized decimal point for a decimal number
		Function GetLocalizedDecimalPoint ()
			dim lDecPoint
			lDecPoint = Mid(CStr(1.1),2,1)
			GetLocalizedDecimalPoint = lDecPoint
		End Function
	</msxsl:script>
	<msxsl:script language="javascript" implements-prefix="user"><![CDATA[
		// This style sheet will not show tables instead of graphs for arrays of values if 
		// 1. TSGraph control is not installed on the machine
		// 2. Using the stylesheet in windows XP SP2. Security settings prevent stylesheets from creatign the GraphControl using scripting. 
		//     Refer to the TestStand Readme for more information.

    // Global Variables 
    var gIndentTables = true; // indent tables or not
    var gStoreStylesheetAbsolutePath = 1; 
    
    // Report Options global variables
    var gIncludeMeasurement = 0;
    var gIncludeLimits = 0;
    var gIncludeArrayMeasurement = 0;
    var gArrayMeasurementFilter = 0;
    var gArrayMeasurementMax = 0;
    var gIncludeTimes = 0;
    var gCheckedForTSGraphControl = 0;
    var gHaveTSGraphControl = 0;
    var gUseLocalizedDecimalPoint = 0;
    var gLocalizedDecimalPoint = "";
    
    // all global color variables
    var gPassedColor = "";
    var gDoneColor = "";
    var gFailedColor = "";
    var gErrorColor = "";
    var gTerminatedColor = "";
    var gSkippedColor = "";
    var gRunningColor = "";
    
    // used as a text color for Report Text
    var gReportTextBgColor = "";
    
    var gAddTable = 0;
    var gMaxBlockLevel = 100; // This is the max blockLevel supported in the report

function dropDown()
{
	menu = document.getElementById("menu1");
	sel = document.getElementById("sel1");
	cObj = sel;
	newLeft = 0;
	newTop = 22;
	if (cObj.offsetParent)
	{
		newLeft += cObj.offsetLeft;
		newTop += cObj.offsetTop;
		
		while(cObj = cObj.offsetParent)
		{
			newLeft += cObj.offsetLeft;
			newTop += cObj.offsetTop;
		}
	}

	menu.style.left = newLeft;
	menu.style.top = newTop;
	menu.style.width = sel.clientWidth;
	menu.style.display='block';
}

    function GetEmptyCellVal() 
    {
    	return "&nbsp;";
    }
    
    function GetAddTable()
    {
      return gAddTable;
    }
    
    function SetAddTable(tableToBeAdded)
    {
      gAddTable = tableToBeAdded;
      return "";
    }
    
    // This function initializes all color global variables
    function InitColorGlobalVariables(nodelist)
    {
      var colorsNode = nodelist.item(0);
      gPassedColor = colorsNode.selectSingleNode("Prop[@Name='Passed']/Value").text;
      gDoneColor = colorsNode.selectSingleNode("Prop[@Name='Done']/Value").text;
      gFailedColor = colorsNode.selectSingleNode("Prop[@Name='Failed']/Value").text;
      gErrorColor = colorsNode.selectSingleNode("Prop[@Name='Error']/Value").text;
      gTerminatedColor = colorsNode.selectSingleNode("Prop[@Name='Terminated']/Value").text;
      gSkippedColor = colorsNode.selectSingleNode("Prop[@Name='Skipped']/Value").text;
      gRunningColor = colorsNode.selectSingleNode("Prop[@Name='Running']/Value").text;
      gReportTextBgColor = colorsNode.selectSingleNode("Prop[@Name='ReportTextBg']/Value").text;
      
      return "";
    }
    
    // This function returns the status background color for the input status node
    function GetStatusColor(nodelist)
    {
      var node = nodelist.item(0);
      var status = node ? node.text : nodelist;
      var statusColor;
      if (status == "Passed")
        statusColor = gPassedColor;
      else if (status == "Done")
        statusColor = gDoneColor;
      else if (status == "Failed")
        statusColor = gFailedColor;
      else if (status == "Error")
        statusColor = gErrorColor;
      else if (status == "Terminated")
        statusColor = gTerminatedColor;
      else if (status == "Running")
        statusColor = gRunningColor;
      else
      {
        if (gSkippedColor == '#FFFF00')
			statusColor = "#b98028";
		else
			statusColor = gSkippedColor;
	  }
      return statusColor; 
    }
    
    function GetReportTextBgColor() { return gReportTextBgColor; }
    function GetErrorColor() { return gErrorColor; }
    
    function SetLocalizedDecimalPoint(lDPoint)
    {
      gLocalizedDecimalPoint = lDPoint;
      return "";
    }
    
    // Function removes white space from String element
    // returns "&nbsp;" if it is an empty string
    function RemoveWhiteSpace(nodelist)
    {
      var retVal = "";
      if(nodelist)
      {
        var node = nodelist.item(0);
        var tempNodeText = node ? node.text : "";
        if( tempNodeText != "")
        {
          var tempNode = "";
          tempNode = tempNodeText.replace(/^\s+/,'');
          if( tempNode == "")
            retVal = "&nbsp;";
          else 
            retVal = tempNode;
        }
        else
          retVal = "&nbsp;";
          
      }
      return retVal;
    }
    
    // Function returns the localized decimal val from a nodelist
    function ReturnLocalizedDecimalVal(nodelist)
    {
      var localizedNode = nodelist;
      if (gUseLocalizedDecimalPoint)
      {
        if (nodelist != null)
        {
          var nodelistItem0 = nodelist.item(0);
          var nodelistItem0Text = nodelistItem0 ? nodelistItem0.text:"";
          if(nodelistItem0Text !="")
            localizedNode = nodelistItem0Text.replace(".", gLocalizedDecimalPoint)
        }
      }
      return localizedNode;
    }
    
    // Function returns the localized decimal val from a node
    function ReturnLocalizedDecimalVal_Node(node)
    {
      var localizedNode = node ? node.text: "";
      if (gUseLocalizedDecimalPoint)
      {
        var tempNode = node ? node.text: "";
        if (tempNode)
          localizedNode = tempNode.replace(".", gLocalizedDecimalPoint)
      }
      return localizedNode;
    }
    
    function AddIndentStartTag()
    {
      var retVal;
      if(gIndentTables == true)
        retVal = "<blockquote>";
      else 
        retVal = "";
        
      return retVal;
    } 
    
    function AddIndentEndTag()
    {
      var retVal;
      if(gIndentTables == true)
        retVal= "</blockquote>";
      else 
        retVal = "";
        
      return retVal;
    }
    
      var gResultLevel = -1;
      var gBlockLevelArray;
      
      // This sets the depth of the results being processed
    function SetResultLevel(curResultLevel)
    {
      if (curResultLevel < gMaxBlockLevel)
        gResultLevel = curResultLevel;
      else 
        gResultLevel = gMaxBlockLevel
      return "";
    }
      
    // This sets the current Block Level of the result being processed
    function SetBlockLevel(curBlockLevel)
    {
      gBlockLevelArray[gResultLevel] = curBlockLevel;
      return "";
    }
    
    function GetResultLevel()
    {
      return gResultLevel;
    }
    
    function GetBlockLevel()
    {
      return gBlockLevelArray[gResultLevel];
    }
    
    // This function creates the BlockLevelArray and init the array to 0;
    function InitBlockLevelArray()
    {
      gBlockLevelArray= new Array(gMaxBlockLevel);
      
      for (var i = 0; i < gMaxBlockLevel; i++)
      {
        gBlockLevelArray[i] = 0;
      }        
      // Set the ResultLevel to 0
      gResultLevel = 0;
      return "";
    }
    
    function ProcessCurrentBlockLevel(nodelist)
    {
      var sRet = "";
      var node = nodelist.item(0);
      var node1 = node.selectSingleNode("Prop[@Name='TS']/Prop[@Name='BlockLevel']");
      var curStepBlockLevel  = -1;
      if (node1)
        curStepBlockLevel = node.selectSingleNode("Prop[@Name='TS']/Prop[@Name='BlockLevel']/Value").nodeTypedValue;				
      if( curStepBlockLevel == -1)
        return sRet;
      if (curStepBlockLevel > GetBlockLevel())
      {
        // Close current table
        if(GetAddTable() == '0')
        {
          sRet = EndTable();
          SetAddTable(1);
        }
        // Add _BlockQuote_
        while(curStepBlockLevel > GetBlockLevel())
        {
          sRet += "<blockquote>\n";
          SetBlockLevel(GetBlockLevel()+1);
        }
        // add Start table
        if(GetAddTable() == '1')
          sRet += BeginTable();   
      }
      else if (curStepBlockLevel < GetBlockLevel())
      {
        // Close current table
        if(GetAddTable() == '0')
        {
          sRet = EndTable();
          SetAddTable(1);
        }
        // Add End _BlockQuote_ 
        while (curStepBlockLevel < GetBlockLevel())
        {
          sRet += "</blockquote>\n";
          SetBlockLevel(GetBlockLevel()-1);
        }
        // add Start table
        if(GetAddTable() == '1')
          sRet += BeginTable();   
      }
      return (sRet + "\n");
    }
      
    function AddEndingBlockQuotesForCurrentSequence()
    {
      var sRet = "";
      while(GetBlockLevel() > 0)
      {
        sRet += "</blockquote>\n";
        SetBlockLevel(GetBlockLevel()-1);
      }
      return sRet;
    }
      
    // This function add symbolic representation to comparison type
    function GetComparisonTypeText ( nodelist )
    {
      var retVal = "";
      var node = nodelist.item(0);
      var compText = node ? node.text : ""
      
      switch (compText)
      {
        case "EQ":
          retVal = compText + "(==)";
          break
        case "NE":
          retVal = compText + "(!=)";
          break
        case "GT":
          retVal = compText + "(>)";
          break
        case "LT":
          retVal = compText + "(<)";
          break
        case "GE":
          retVal = compText + "(>=)";
          break
        case "LE":
          retVal = compText + "(<=)";
          break
        case "GTLT":
          retVal = compText + "(> <)";
          break
        case "GELE":
          retVal = compText + "(>= <=)";
          break
        case "GELT":
          retVal = compText + "(>= <)";
          break
        case "GTLE":
          retVal = compText + "(> <=)";
          break
        case "LTGT":
          retVal = compText + "< >";
          break
        case "LEGE":
          retVal = compText + "<= >=";
          break
        case "LEGT":
          retVal = compText + "<= >";
          break
        case "LTGE":
          retVal = compText + "< >=";
          break
        case "LOG":
          retVal = nodelist;
          break
        case "":
          retVal = "&nbsp;";
        default:
          retVal = compText;
        }
      return retVal;
    }
    
    // This function first converts all back-slashes into forward-slashes 
		// and strips out the name portion of the input file path
    function GetFolderPath(sFilePath)
		{
			var sConvertedFilePath;
			var index = sFilePath.indexOf("\\");
			if (index == -1)
				sConvertedFilePath = sFilePath;
			else
			{
				sConvertedFilePath = "";
				do
				{	// if it is a network path, parse it and replace
					sConvertedFilePath += sFilePath.substring(0,index) + "/";
					sFilePath = sFilePath.substring(index+1,sFilePath.length);
					index = sFilePath.indexOf("\\");
				}
        while (index != -1);
        sConvertedFilePath += sFilePath;
      }
			var sFolderPath = "";
			index = sConvertedFilePath.lastIndexOf("/");
			if (index != -1)
				sFolderPath = sConvertedFilePath.substring(0,index) + "/";
			return sFolderPath;
		}
		
		// This function initializes the base or prefix path global variables
		function InitPaths(nodelist)
		{
			var reportOptionsNode = nodelist.item(nodelist.length-1);
			var stylesheetPath = reportOptionsNode.selectSingleNode("Prop[@Name='StylesheetPath']/Value").text;
			var storeStylesheetAbsolutePath = reportOptionsNode.selectSingleNode("Prop[@Name='StoreStylesheetAbsolutePath']/Value").text;
			gStoreStylesheetAbsolutePath = (storeStylesheetAbsolutePath == "True") ? 1 : 0;
			return "";
		}
		
		// This function initializes all report options flag global variables
		function InitFlagGlobalVariables(nodelist)
		{
			var reportOptionsNode = nodelist.item(0);
			gIncludeMeasurement = (reportOptionsNode.selectSingleNode("Prop[@Name='IncludeMeasurements']/Value").nodeTypedValue == 'True');
			gIncludeLimits = (reportOptionsNode.selectSingleNode("Prop[@Name='IncludeLimits']/Value").nodeTypedValue == 'True');
			gIncludeArrayMeasurement = reportOptionsNode.selectSingleNode("Prop[@Name='IncludeArrayMeasurement']/Value").nodeTypedValue;
			gArrayMeasurementFilter = reportOptionsNode.selectSingleNode("Prop[@Name='ArrayMeasurementFilter']/Value").nodeTypedValue;
			gArrayMeasurementMax = reportOptionsNode.selectSingleNode("Prop[@Name='ArrayMeasurementMax']/Value").nodeTypedValue;
			gIncludeTimes = (reportOptionsNode.selectSingleNode("Prop[@Name='IncludeTimes']/Value").nodeTypedValue == 'True') && 
                      (reportOptionsNode.selectSingleNode("Prop[@Name='IncludeStepResults']").nodeTypedValue == 'True');
			var useLocalizedDecimalPointNode = reportOptionsNode.selectSingleNode("Prop[@Name='UseLocalizedDecimalPoint']");
			// Do this so that old reports can also use the new style sheet
			if (useLocalizedDecimalPointNode)
        gUseLocalizedDecimalPoint = (reportOptionsNode.selectSingleNode("Prop[@Name='UseLocalizedDecimalPoint']/Value").nodeTypedValue == 'True');
			return "";
		}
			
		function AreMeasurmentsIncluded() {	return gIncludeMeasurement;}
			
		function AreLimitsIncluded() { return gIncludeLimits; }
    
    function AreTimesIncluded()  { return gIncludeTimes; }
			
		// This function returns the serial number of the input node or returns the string NONE
		function GetSerialNumber(nodelist)
		{
			var node = nodelist.item(0);
			var text = node ? node.text : "";
			return (text == "") ? "NONE" : text;
		}
		//This function return the list item for the total time of the UUT
		function GetTotalTime(nodelist)
		{
			if (gIncludeTimes)
			{
				var node = nodelist.item(0);
				var text = node ? ReturnLocalizedDecimalVal_Node(node): "";
				// add two cells for time
				return "<td valign='bottom' nowrap='nowrap' align='center'><font size='1'>" + ((text == '') ? "N/A" : (text + " seconds")) + "</font></td>\n";
			}
			else
				return "&nbsp;"; 
		}
		// This function returns true if step Failure causes sequence failure 
		function GetIsCriticalFailure(nodelist)
		{
			var node = nodelist.item(0);
			var	sfcsfNodeText = "";
			if ( node)
			{
				var sfcsfNode = node.parentNode.selectSingleNode("Prop[@Name='StepCausedSequenceFailure']") ;
				sfcsfNodeText = (sfcsfNode != null) ? sfcsfNode.selectSingleNode("Value").text:"";
				sfcsfNodeText  = (sfcsfNodeText == "True") ? "True" : "";
			}
			return 	sfcsfNodeText;
		}
		
		function GetIsCriticalFailureFromStatus(nodelist)
		{
			var node = nodelist.item(0);
			var	sfcsfNodeText = "";
			if ( node)
			{
				var sfcsfNode = node.parentNode.selectSingleNode("Prop[@Name = 'TS']/Prop[@Name='StepCausedSequenceFailure']") ;
				sfcsfNodeText = (sfcsfNode != null) ? sfcsfNode.selectSingleNode("Value").text:"";
				sfcsfNodeText  = (sfcsfNodeText == "True") ? "True" : "";
			}
			return 	sfcsfNodeText;
		}
			
		// This function returns the Id value of the input result node 
		function GetResultId(nodelist)
		{
			var node = nodelist.item(0);
			var idNode = node.parentNode.selectSingleNode("Prop[@Name='Id']");
			return (idNode != null) ? idNode.selectSingleNode("Value").text : "";
		}
		
		// This function returns the loop index text or null if LoopIndex isnt found
		function GetLoopIndex(nodelist)
		{
			var node = nodelist.item(0);
			var valueNode = node.parentNode.selectSingleNode("Prop[@Name='LoopIndex']/Value");
      var sRet = "";
			if (valueNode != null)
				sRet = " (Loop Index: " + valueNode.text + ")";
				
			return sRet;
		}
		
		function GetStdIndentation()
		{
						return "";
	//		return "&nbsp;&nbsp;";
    }
			
		// This function returns indentaion string if the step is a loop result 
		function GetInitialIndentation(nodelist)
		{
		  var isLoopResultStepName = GetLoopIndex(nodelist);
		  var sRet = "";
		  if (isLoopResultStepName != "")
    		  sRet = GetIndent(2);
    		  
	    return sRet;
		}
		
		// This function checks if it is a flow control step or not
		function IsNotFlowControlStep(nodelist)
		{
			var node = nodelist.item(0);
			var stepType = node.selectSingleNode("Prop[@Name='TS']/Prop[@Name='StepType']/Value");
			stepTypeText = stepType.text;
			
			if (stepTypeText.match("NI_Flow") == "NI_Flow")
				return false;
			else 
        return true;
		}
		
		// This function returns reportText to be attached to the step Name if it is a flow control step
		function GetStepNameAddition(nodelist)
		{
			var node = nodelist.item(0);
			if (node)
			{
				var stepType = node.parentNode.selectSingleNode("Prop[@Name='StepType']/Value");
				var reportText = node.parentNode.parentNode.selectSingleNode("Prop[@Name='ReportText']/Value");
				var stepTypeText = stepType?stepType.text:"";
				var reportTextVal = reportText ? reportText.text: "";
				var sRet = " ";
				if (stepTypeText.match("NI_Flow") == "NI_Flow")
				{
					if (stepTypeText.match("NI_Flow_End") == "NI_Flow_End")
					{
						reportTextVal = reportTextVal.replace("(","");
            reportTextVal = reportTextVal.replace(")","");
          }
//22.06.11					sRet += reportTextVal;
					
				}
        return sRet;
      }
			return " ";
		}
		
		// This function takes an element value and 
    // 1. adds a _br_ to the output when it finds a newline character.
		// 2. Removes \r from the text
		function RemoveIllegalCharacters(nodelist)
		{
			var node = nodelist.item(0);
			var text = node.firstChild.text;
    	var sRet = "";
    	var newLine = "<br/>";
			var index = text.indexOf("\n");
			
      if (index == -1)
				sRet = text;
      while(index != -1)
      {	
				sRet += text.substring(0,index) + newLine;
				text = text.substring(index+1,text.length);
				index = text.indexOf("\n");
				if (index == -1)
					sRet += text;
			}
			
			var newText = sRet;
  		sRet = "";
  		
      if (newText != "")
      {
        var slashR = "\\r";
   		  index = newText.indexOf(slashR);
        if (index == -1)
          sRet = newText;
        else
        {
      		while(index != -1)
      	  {
    			  sRet += newText.substring(0,index);
        	  newText = newText.substring(index+2, newText.length);
    			  index = newText.indexOf(slashR);
    			  if (index == -1)
    			    sRet += newText;
    			}
    		}
		  }
		  // remove white space 
      var tempNode = "";
      tempNode = sRet.replace(/^\s+/,'');
      if (tempNode == "")
        tempNode = "&nbsp;"
      sRet = tempNode;
			return sRet;
		}
			
      
      //GraphArray is an object to help graph 2D arrays
      function GraphArray(sLBound, sHBound)
      {
          this.LBoundElements = (sLBound.substring(1).replace(/]/g,"")).split("[");
          this.HBoundElements = sHBound.substring(1).replace(/]/g,"").split("[");
          this.Dimensions = sLBound.split("[").length - 1;
          
          this.SizeString = "";
          var i = 0;
                  
          for(i = 0; i < this.LBoundElements.length; ++i)
          {
              this.SizeString += "[" + this.LBoundElements[i] + ".." + this.HBoundElements[i] + "]";
          }
          
          this.GraphSize = this.HBoundElements[this.Dimensions - 1] - this.LBoundElements[this.Dimensions - 1] + 1;
          this.NumberOfGraphs = 1;
          if(this.Dimensions == 2)
              this.NumberOfGraphs = this.HBoundElements[0] - this.LBoundElements[0] + 1;
          
          this.Graphs = new Array();
          for(i = 0; i < this.NumberOfGraphs; ++i)
          {
              this.Graphs[i] = new Array();
          }
          
          //GraphArray methods:
          this.AddElementToGraph = AddElementToGraph;
          this.GetGraphData = GetGraphData;
      }
      
      function AddElementToGraph(element)
      {
          if(this.Dimensions == 1)
          {
              this.Graphs[0].push(element.text);
          }
          else
          {
              var elementIndexes = (element.getAttribute("ID").substring(1).replace(/]/g,"")).split("[");
              this.Graphs[elementIndexes[0] - this.LBoundElements[0]].push(element.text);
          }
      }
      
      function GetGraphData(index)
      {
           return this.Graphs[index].join(",");
      }
      
    // This function creates a graph using an array of elements.  The global variable gGraphCount allows for 
		// multiple graphs to appear on one page since each graph must have a unique id.
		// NOTE: Graphing only works for 1D arrays
		
		var gGraphCount = 0;
		
		function GetArrayTableOrGraph(valueNodes,nMax,bDoDecimation,bGetTable, graphArrayObj)
		{
			var sRet = "";
			var sArray = "";
			var inc = (bDoDecimation) ? (valueNodes.length / nMax) : 1;
			var n = 0;
			var i = 0;
			var fIdx = 0;
      var nIdx = 0;
			var valueNode = valueNodes.item(0);
			var addedTableElements = 0;
				
			// if creating a graph, make sure the graph control is installed
			// if not installed, show the data as a table instead
			if (bGetTable == 0)
			{
				if (gCheckedForTSGraphControl == 0)
				{
					gCheckedForTSGraphControl = 1;
					try
					{
						var xObj = new ActiveXObject("TsGraphControl.GraphControl");
						gHaveTSGraphControl = (xObj != null) ? 1 : 0;
            
            //Check the dimensions of the array
            if(graphArrayObj.Dimensions > 2)
  			    		bGetTable = 1;
					}
					catch(e)
					{
						gHaveTSGraphControl  = 0;
					}
				}
				if (gHaveTSGraphControl == 0)
					bGetTable = 1;
			}
			
			if (bGetTable)
			{
				sRet += "<td colspan='6'>";
				sRet += "<font size='1'>";
			}
			else
			{
				sRet += "<td colspan='6'>";
        if(graphArrayObj.Dimensions == 2)
        {
            //this is to fix the decimation to each graph
            nMax = nMax * graphArrayObj.NumberOfGraphs;
            inc = (bDoDecimation) ? (graphArrayObj.GraphSize / nMax) : 1;
        }
			}
			while (valueNode && (n < nMax))
			{
				if (bGetTable)
				{	
					var sText = ReturnLocalizedDecimalVal_Node(valueNode);
          var sID =  valueNode.getAttribute("ID");
					sRet += sID + " = '" + sText + "'<br/>";
					addedTableElements = 1;
				}
				else
				{
            graphArrayObj.AddElementToGraph(valueNode);
				}
				fIdx += inc;
				nIdx = Math.floor(fIdx);
				do
				{
					valueNode = valueNodes.nextNode();
					i++;
				}
				while (valueNode && (i < nIdx));
				n++;
			}
			if (bGetTable)
			{	
				if (addedTableElements == 0)
					sRet += "&nbsp;";
				sRet += "</font>";
			}
			else
			{
				if (valueNodes.length > 0)
				{
					sRet += "<object classid='clsid:BA578A47-350E-4115-811B-C80DB80EBD33' ProgID='TsGraphControl.GraphControl' id='CWGRAPH";
					sRet += gGraphCount + "' height='200' style='LEFT: 0px; TOP: 0px' width='100%'> </object>";
          sRet += "<script defer id='plotOnGraph' LANGUAGE='VBScript'>";
          var i = 0;
          for(i = 0; i < graphArrayObj.NumberOfGraphs; ++i)
          {
              sRet += " Call CWGRAPH" + gGraphCount + ".PlotY(Array(" + graphArrayObj.GetGraphData(i) + "),0,1) \n";
          }
          sRet += "</script>";
					gGraphCount++;
				}
				else 
					sRet += "&nbsp;";
			}
			sRet += "</td>\n";
      return sRet;
    }
			
		// This function generates an indentation string based on the level
    function GetIndent(nLevel)
    {
      var sIndent = "";
      for (var i = 0; i < nLevel; i++)
        sIndent += GetStdIndentation();
      
      return sIndent;
    }
    
    // This function generates a result row that will be inserted in the table
    function GetResultLine (name, value, parentNode, nLevel)
    {
		var sRet = "";
    
		var propLabel = (name != null) ? name: parentNode;
      
		sRet += "<tr>";
		sRet += "<td valign='top' nowrap='nowrap'>";
		sRet += "<font size='1'>" ;
		sRet +=  GetIndent(nLevel) + propLabel+ ":";
		sRet += "</font></td>\n";
		sRet += "<td valign='top' nowrap='nowrap' colspan='6'>";
		sRet += "<font size='1'>" ;
		// Special case, results are 'empty string'
		if (value == "")
			sRet+="''</font></td>\n";
		else
		{
			// remove white space 
			var tempNode = "";
			tempNode = value.replace(/^\s+/,'');
			if (tempNode == "")
				tempNode = "&nbsp;"
			sRet += tempNode+ "</font></td>\n";
		}
		sRet += "</tr>\n";
		return sRet;
    }
    
		// This function adds an array to the report as a graph or table (if the elements are numbers) and 
		// as individual values otherwise
    function AddArrayToReport (propNode, propName, propLabel, nLevel)
    {
      var sRet = "";
      var nMax = 0;
      var bAddArray = true;
      var bDoDecimation = false;
      var valueNodes = propNode.selectNodes("Value");
      var sElementType = propNode.getAttribute("ElementType");
      var graphArrayObj = new GraphArray(propNode.getAttribute("LBound"), propNode.getAttribute("HBound"));
				
      // Include All
      if (gArrayMeasurementFilter == 0)
        nMax = valueNodes.length;
			// Include Up To Max
			else if (gArrayMeasurementFilter == 1)
				nMax = (valueNodes.length < gArrayMeasurementMax) ? valueNodes.length : gArrayMeasurementMax;
			// Exclude If Larger Than Max
			else if (gArrayMeasurementFilter == 2)
			{
        if (valueNodes.length > gArrayMeasurementMax)
				{
					bAddArray = false;
					nMax = 0;
				}
				else
					nMax = valueNodes.length;
			}
      // Decimate If Larger Than Max
			else if (gArrayMeasurementFilter == 3)
			{
				if (valueNodes.length > gArrayMeasurementMax)
				{
					bDoDecimation = true;
					nMax = gArrayMeasurementMax;
				}
				else
					nMax = valueNodes.length;
			}
			// if it's a Numeric Array
			if (sElementType == "Number")
			{
        if (gIncludeArrayMeasurement != 0)
				{
					if (bAddArray)
					{
						var sArray = GetArrayTableOrGraph (valueNodes, nMax, bDoDecimation, (gIncludeArrayMeasurement == 1), graphArrayObj);
						// Add Label
						sRet += "<tr><td valign='top'>";
						if (valueNodes.length > 0)
							sRet += "<font size='1'>" + GetIndent(nLevel) + propLabel + graphArrayObj.SizeString + ":" + "</font>" + "</td>\n";
						else
							sRet += "<font size='1'>" + GetIndent(nLevel) + propLabel + "[0.." + "empty" + "]" + ":" + "</font>" + "</td>\n";
							
						// Add Array Table or Graph
						sRet += sArray;
						sRet += "</tr>\n";
					}
				}
			}
			else if (sElementType == "String" || sElementType == "Boolean")
			{
				if (gIncludeArrayMeasurement != 0)
				{
					if (bAddArray)
					{
						var sArray = GetArrayTableOrGraph (valueNodes, nMax, bDoDecimation, true, graphArrayObj);
						// Add Label
						sRet += "<tr><td valign='top'>";
						if (valueNodes.length > 0)
							sRet += "<font size='1'>" + GetIndent(nLevel) + propLabel + graphArrayObj.SizeString + ":" + "</font></td>\n";
						else
							sRet += "<font size='1'>" + GetIndent(nLevel) + propLabel + "[0.." + "empty" + "]" + ":" + "</font>" + "</td>\n";
						// Add Table 
						sRet += sArray;
						sRet += "</tr>\n";
					}
				}
			}
			// otherwise recurse through the array values
			else
			{	
				// Add Label
				sRet += "<tr><td colspan='7'>";
				sRet += "<font size='1'>" + GetIndent(nLevel) + propLabel + ":" + "</font></td></tr>\n";
				// Add value nodes
				var valueNodes = propNode.selectNodes("Value");
				var valueNode = valueNodes.item(0);
				while (valueNode)
				{
					var valueName = propLabel + valueNode.getAttribute("ID");
					var valuePropNodes = valueNode.selectNodes("Prop[@Flags]");
					sRet += PutFlaggedValuesInReportForArrayElements (valuePropNodes, valueName, 1, nLevel+1);
					valueNode = valueNodes.nextNode();
				}
			}
      return sRet;
    }
    
    // This function adds rows to the table depending on the type of node and flags and options
    function AddIfFlagSet (propNode, propLabel, parentPropName, bInclude, nLevel)
    {
		var sRet = "";
		var propFlags = propNode.getAttribute("Flags");
		var bIncludeInReport = ((propFlags & 0x2000) == 0x2000);
		var bIsMeasurementValue = ((propFlags & 0x0400) == 0x0400);
		var bIsLimits = ((propFlags & 0x1000) == 0x1000);
		var propName = propNode.getAttribute("Name");
//		var propLabel = (propName != null) ? propName: parentPropName;
		var propType = propNode.getAttribute("Type");

		// return if it is TS properties or Error Properties 
		if (propName == "TS" || propName == "Error")
					return sRet;
		
		var childPropNodes = propNode.selectNodes("Prop[@Flags]");		
		
		if ((bInclude || bIncludeInReport) && 
			!((bIsMeasurementValue && !gIncludeMeasurement) || (bIsLimits && !gIncludeLimits)) )
		{
			// determine what to do with property based on type
			if (propType == "Array")
			{	
				// Handle Arrays
				var arrayElemPropTypeName = "";
				if (propName == "Measurement")
					arrayElemPropTypeName = propNode.firstChild.getAttribute("TypeName");
				if (arrayElemPropTypeName != "NI_LimitMeasurement")
					sRet += AddArrayToReport (propNode, propName, propLabel, nLevel);
			}
			else
			{	
				var propValueNode = propNode.selectSingleNode("Value");
				if (propValueNode)
				{
					var parentPropType = propNode.parentNode.getAttribute("Type");
					if (
					  !(propName == 'String' && propType == 'String' && parentPropType == 'TEResult') && // String value Test
					  !(propName == 'String' && propType == 'String' && parentPropName == 'Limits') && // String value Test
					  !(propName =='Numeric' && propType == 'Number' && parentPropType == 'TEResult') && // Numeric Limit Test
					  !(propName == 'PassFail' && propType == 'Boolean' && parentPropName == 'Limits') && // Pass Fail Test
					  !(propName == 'Comp' && propType == 'String' && parentPropType == 'TEResult')  && // Comparison Property
					  !(propName == 'Units' && propType == 'String' && parentPropType == 'TEResult') && // Units Property
					  !(propName == 'Low' && propType =='Number' && parentPropName == 'Limits') && // Low Limits property
					  !(propName == 'High' && propType =='Number' && parentPropName == 'Limits') // High limits Property
					)
					{
						var localizedVal = propValueNode.text;
						if (propType == "Number")
							localizedVal = ReturnLocalizedDecimalVal_Node(propValueNode);
						sRet += GetResultLine (propName, localizedVal, propLabel, nLevel);
					}
				}
				else  // look for child property node with flags
				{
					if (childPropNodes.length > 0)
					{
						if(propLabel != 'Limits')
						{
							// Add Label
							sRet += "<tr>";
							sRet += "<td nowrap='nowrap' colspan='7'> ";
							sRet += "<font size='1'>" + GetIndent(nLevel) + propLabel +":";
							sRet += "</tr>\n";
						}
						// Add children prop nodes
						sRet += PutFlaggedValuesInReport (childPropNodes, propName, 1, nLevel+1);
					}
				}
			}
		}
		else
		{
			//Add children prop nodes
			// Array values will only be processed if elementType is not "numeric", "String", "boolean", "ObjRef"
			if (propType == "Array")
			{
			
				var arrayElemPropTypeName = "";
				if (propName == "Measurement")
					arrayElemPropTypeName = propNode.firstChild.getAttribute("TypeName");
				if (arrayElemPropTypeName != "NI_LimitMeasurement")
				{
					var sElementType = propNode.getAttribute("ElementType");
					if (sElementType == "Obj")
					{ 
						// Get the value nodes
						var valueNodes = propNode.selectNodes("Value");
						var valueNode = valueNodes.item(0);
						while (valueNode)
						{
							var childPropNodes = valueNode.selectNodes("Prop[@Flags]");
							if (childPropNodes.length > 0)
								sRet += PutFlaggedValuesInReport (childPropNodes, propName, 0, nLevel);
							valueNode = valueNodes.nextNode();
						}
					}
				}
			}
			else
			{
				if (childPropNodes.length > 0)
					sRet += PutFlaggedValuesInReport (childPropNodes, propName, 0, nLevel);
			}
		}
		
		return sRet;
	}
		
		// This function iterates through the input Prop nodes and calls AddIfFlagSet for each
		function PutFlaggedValuesInReport (propNodes, parentPropName, bInclude, nLevel)
		{
			var sRet = "";
			var propNode = propNodes.item(0);
			
			while (propNode)
			{
				var propName = propNode.getAttribute("Name");
				var propLabel = (propName != null) ? propName: parentPropName;
				sRet += AddIfFlagSet (propNode, propLabel, parentPropName, bInclude, nLevel);
				propNode = propNodes.nextNode();
			}
			return sRet;
		}
    
		// This function iterates through the input Prop nodes and calls AddIfFlagSet for each
		function PutFlaggedValuesInReportForArrayElements (propNodes, parentPropName, bInclude, nLevel)
		{
			var sRet = "";
			var propNode = propNodes.item(0);
			
			while (propNode)
			{
				var propName = propNode.getAttribute("Name");
				var propLabel = parentPropName;
				if(propName != null) 
					propLabel = propLabel + " (" + propName + ")";
				sRet += AddIfFlagSet (propNode, propLabel, parentPropName, bInclude, nLevel);
				propNode = propNodes.nextNode();
			}
			return sRet;
		}
		
		
    // This function returns either the (full) file URL or only the file name depending if storing absolute
    // or relative path to the stylesheet
    function GetLinkURL(nodelist)
    {
      var node = nodelist.item(0);
      return (gStoreStylesheetAbsolutePath) ? node.getAttribute("URL") : node.getAttribute("FileName");
    }
    
    // This function initializes the global array used to store loop index counts
    var gLoopNodeArray;
    var gLoopCounterArray;
    var gFirstLoopIndexArray;
    var gLoopStackDepth = -1;
    function InitLoopArray(nodelist)
    {
      var node = nodelist.item(0);
      var loopStartNodes = node.selectNodes(".//Prop[@Name='NumLoops']")
      var maxStackDepth = loopStartNodes.length;
      gLoopNodeArray = new Array(maxStackDepth);
      gLoopCounterArray = new Array(maxStackDepth);
      gFirstLoopIndexArray = new Array(maxStackDepth);
      for (var i = 0; i < maxStackDepth; i++)
      {
        gLoopNodeArray[i] = null;
        gLoopCounterArray[i] = 0;
        gFirstLoopIndexArray[i] = false;
      }
      return "";
    }
    
		// This function stores necessary information used to process loop index step results.  
		// The Loop Stack Depth counter is not incremented here since loop step results may be disabled.
		function BeginLoopIndices(nodelist)
		{
			var node = nodelist.item(0);
			var loopStackDepthPlus1 = gLoopStackDepth + 1;
			gLoopNodeArray[loopStackDepthPlus1] = node;
			gLoopCounterArray[loopStackDepthPlus1] = node.selectSingleNode("Prop[@Name='TS']/Prop[@Name='NumLoops']/Value").nodeTypedValue;
			gFirstLoopIndexArray[loopStackDepthPlus1] = true;
			return "";
		}

    // This function returns the HTML for the Table Row of the Loop Indices button control
    function GetLoopIndicesTableEntry(node)
    {
        var stepName = node.selectSingleNode("Prop[@Name='TS']/Prop[@Name='StepName']/Value").nodeTypedValue;
      var stepGroup = node.selectSingleNode("Prop[@Name='TS']/Prop[@Name='StepGroup']/Value").nodeTypedValue;
      var sRet = "";
      sRet += "<tr>";
      sRet += "<td colspan='1'>";
      sRet += GetStdIndentation();
      sRet += "<font size='1'>" + stepName + " (Loop Indices)</font></td>\n";
      sRet += "<td colspan='6'>&nbsp;</td>\n";
      sRet += "</tr>\n";
      return sRet;
    }
    
		// This function checks to see if this is the first loop step result.  If yes, it opens the div and increments the loop stack depth counter.
		function TestForStartLoopIndex()
		{
			if (gFirstLoopIndexArray[gLoopStackDepth + 1])
			{
				var node;
				var id;
				gLoopStackDepth++;
				gFirstLoopIndexArray[gLoopStackDepth] = false;
				node = gLoopNodeArray[gLoopStackDepth];
				id = node.selectSingleNode("Prop[@Name='TS']/Prop[@Name='Id']/Value").nodeTypedValue;
				return GetLoopIndicesTableEntry(node) + "<div class='child' id='el" + id + "Child'><dir>";
			}
			else
				return "";
		}
		
		// This function checks to see if all loop step results have been seen.  If yes, it closes the div and decreases the loop stack depth counter.
		function TestForEndLoopIndex()
		{
			if (--gLoopCounterArray[gLoopStackDepth] == 0)
			{
				gLoopNodeArray[gLoopStackDepth] = null;
				gLoopStackDepth--;
				return "</dir></div>";
			}
			else
				return "";
		}
		
    			  
    // These functions are used to store the gLoopStackDepth to prevent issues while a sequence call step is looping and 
    // a step inside the sequence is also looping but has disabled result recording for each iteration
    var gMaxLoopingArraySize = 100;
	var gLoopingInfoArray;
    function InitLoopingInfoArray()
	{
		gLoopingInfoArray = new Array(gMaxLoopingArraySize);
		for (var i = 0; i < gMaxLoopingArraySize; i++)
		{
			gLoopingInfoArray[i] = 0;
		}
		// ResultLevel is set in InitBlockLevelArray()
		return "";
	}
	   
    function StoreCurrentLoopingLevel()
    {
		gLoopingInfoArray[GetResultLevel()] = gLoopStackDepth;
		return "";
    }
    
    function RestoreLoopingLevel()
    {
		gLoopStackDepth = gLoopingInfoArray[GetResultLevel()] ;
		gFirstLoopIndexArray[gLoopStackDepth+1] = false;
		return "";
    }
    
		//This function adds a beginning Table Element.
		function BeginTable()
		{
			SetAddTable(0);
			return   	"\n<table x:str border=1 cellpadding=0 cellspacing=0 width=1000 style='border-collapse: collapse;table-layout:fixed;width:1300pt'>" +
						"<tr>" + 
						"<td rowspan='2' valign='bottom' align='center' width = 2%><font size='1'><b>Date</b></font></td>\n" +
						"<td rowspan='2' valign='bottom' align='center' width = 2%><font size='1'><b>Time</b></font></td>\n" +
						"<td rowspan='2' valign='bottom' align='center' width = 5%><font size='1'><b>StepType</b></font></td>\n" +
						"<td rowspan='2' valign='bottom' align='center' width = 10%><font size='1'><b>SequenceFileName</b></font></td>\n" +
						"<td rowspan='2' valign='bottom' align='center' width = 10%><font size='1'><b>SequenceCallName</b></font></td>\n" +
						"<td rowspan='2' valign='bottom' align='center' width = 10%><font size='1'><b>StepName</b></font></td>\n" +
						"<td rowspan='2' valign='bottom' align='center' width = 4%><font size='1'><b>Measurement</b></font></td>\n" +
						"<td rowspan='2' valign='bottom' align='center' width = 3%><font size='1'><b>TestCriteria</b></font></td>\n" +
						"<td rowspan='2' valign='bottom' align='center' width = 5%><font size='1'><b>TestResult</b></font></td>\n" + 
						"<td rowspan='2' valign='bottom' align='center' width =  3%><font size='1'><b>Units</b></font></td>\n" +
						"<td rowspan='2' valign='bottom' align='center' width =  3%><font size='1'><b>Low Limit</b></font></td>\n" +
						"<td rowspan='2' valign='bottom' align='center' width =  3%><font size='1'><b>High Limit</b></font></td>\n" +
						"<td rowspan='2' valign='bottom' align='center' width =  7%><font size='1'><b>Comparison Type</b></font></td>\n" +
						"</tr>\n"; 
		}
			
    //This function adds an ending Table Element.
    function EndTable()
    {
      return "</table>";
    }
	]]></msxsl:script>
					
	<xsl:output method="html"/>
	
	<xsl:template match="/">
		<HTML>
			
			<head>
											
			</head>
			<BODY>
					<font FACE="VERDANA">
					<xsl:apply-templates select="//Report"/>
				</font>
			</BODY>
		</HTML>
	</xsl:template>
	
  <xsl:template match="Report[@Type='UUT']">
		<xsl:value-of select="user:InitFlagGlobalVariables(Prop[@Name='ReportOptions'])"/>
		<xsl:value-of select="user:InitColorGlobalVariables(Prop[@Name='ReportOptions']/Prop[@Name='Colors'])"/>
		<xsl:value-of select="user:InitLoopArray(.)"/>
		<xsl:value-of select="user:InitBlockLevelArray()"/>
		<xsl:value-of select="user:InitLoopingInfoArray()"/>
		<a>
			<xsl:attribute name="name"><xsl:value-of select="@Link"/></xsl:attribute>
		</a>
		<xsl:value-of disable-output-escaping="yes" select="user:BeginTable()"/>
		<tr>
		<xsl:apply-templates select="Prop/Prop[@Name='TS']/Prop[@Name='SequenceCall']"/>
		</tr>
		<hr size="2" align="center" WIDTH="87%"/>
					
		</xsl:template>
	
		
	<xsl:template match="Report[@Type='Batch']">
		<xsl:value-of select="user:InitFlagGlobalVariables(Prop[@Name='ReportOptions'])"/>
		<h3>
			<font size="2">
				<xsl:value-of select="@Title"/>
			</font>
		</h3>
		<h4>
			<table border="1" cellpadding="2" cellspacing="0" rules="all" width="47%">
				<tr valign="top">
					<td nowrap="nowrap" align="center" width="7%">
						<font size="1">
							<b>Station ID</b>
						</font>
					</td>
					<td nowrap="nowrap" align="center" width="12%">
						<font size="1">
							<b>Batch Serial Number</b>
						</font>
					</td>
					<td align="center" width="11%">
						<font size="1">
							<b>Date</b>
						</font>
					</td>
					<td align="center" width="8%">
						<font size="1">
							<b>Time</b>
						</font>
					</td>
					<td align="center" width="9%">
						<font size="1">
							<b>Operator</b>
						</font>
					</td>
				</tr>
				<tr valign="top">
					<xsl:apply-templates select="Prop[@Name='StationInfo']/Prop[@Name='StationID']"/>
					<td align="center">
						<font size="1">
							<xsl:value-of disable-output-escaping="yes" select="user:GetSerialNumber(@BatchSerialNumber)"/>
						</font>
					</td>
					<xsl:apply-templates select="Prop[@Name='StartDate']"/>
					<xsl:apply-templates select="Prop[@Name='StartTime']"/>
					<xsl:apply-templates select="Prop[@Name='StationInfo']/Prop[@Name='LoginName']"/>
				</tr>
			</table>
		</h4>
		<xsl:apply-templates select="BatchTable"/>
		<h3>
			<font size="2">
				End Batch Report
			</font>
		</h3>
		<hr size="2" align="center" WIDTH="87%"/>
	</xsl:template>
	<xsl:template match="Prop[@Name='StationID']">
		<td nowrap="nowrap" align="center">
			<font size="1">
				<xsl:value-of select="Value"/>
			</font>
		</td>
	</xsl:template>
	<xsl:template match="Prop[@Name='BatchSerialNumber']">
		<xsl:if test="Value != ''">
			<td nowrap="nowrap" align="center">
				<font size="1">
					<xsl:value-of select="Value"/>
				</font>
			</td>
		</xsl:if>
	</xsl:template>
	<xsl:template match="Prop[@Name='TestSocketIndex']">
		<xsl:if test="Value != -1">
			<td nowrap="nowrap" align="center">
				<font size="1">
					<xsl:value-of select="Value"/>
				</font>
			</td>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="Prop[@Name='StartDate']">
		<td nowrap="nowrap" align="center">
			<font size="1">
				<xsl:value-of select="Prop[@Name='ShortText']/Value"/>
			</font>
		</td>
	</xsl:template>
	<xsl:template match="Prop[@Name='StartTime']">
		<td nowrap="nowrap" align="center">
			<font size="1">
				<xsl:value-of select="Prop[@Name='Text']/Value"/>
			</font>
		</td>
	</xsl:template>
	<xsl:template match="Prop[@Name='LoginName']">
		<td nowrap="nowrap" align="center">
			<font size="1">
				<xsl:value-of select="Value"/>
			</font>
		</td>
	</xsl:template>
	<xsl:template match="Prop[@Name='TotalTime']">
		<xsl:value-of disable-output-escaping="yes" select="user:GetTotalTime(Value)"/>
	</xsl:template>
	<xsl:template match="Prop[@Name='SequenceCall']">
		<xsl:if test="Prop[@Name='ResultList'] and Prop[@HBound != '[]']">
			<xsl:value-of disable-output-escaping="yes" select="user:AddIndentStartTag()"/>
			<!--<font size="1">
				<b>
					<br/>
					<nobr>Begin Sequence: <xsl:value-of select="Prop[@Name='Sequence']/Value"/>
						<br/> (<xsl:apply-templates select="Prop[@Name='SequenceFile']"/>)</nobr>
				</b>
			</font>-->
			<!--<xsl:value-of disable-output-escaping="yes" select="user:BeginTable()"/>-->
			<xsl:apply-templates select="Prop[@Name='ResultList']/Value[@ID]/Prop[@Type='TEResult']"/>
			
			<xsl:value-of disable-output-escaping="yes" select="user:AddIndentEndTag()"/>
		</xsl:if>
		<xsl:if test="Prop[@Name='ResultList']">
			<xsl:if test="Prop[@Name='ResultList'] and Prop[@HBound = '[]']">
				<br/>
			</xsl:if>
		</xsl:if>
		<!-- In case the resultList is deleted and does not exist in the stream -->
		<xsl:if test="not (Prop[@Name='ResultList'])">
			<font size="1">
				<br/>
        No Sequence Results Found
     	</font>
		</xsl:if>
	</xsl:template>
	<xsl:template match="Prop[@Name='PostAction']">
		<xsl:if test="Prop[@Name='ResultList']">
			<xsl:if test="Prop[@Name='ResultList'] and Prop[@HBound != '[]']">
				<xsl:value-of disable-output-escaping="yes" select="user:AddIndentStartTag()"/>
				<font size="1">
					<b>
						<br/>
						<nobr>Begin Sequence: <xsl:value-of select="Prop[@Name='Sequence']/Value"/>
							<br/> (<xsl:apply-templates select="Prop[@Name='SequenceFile']"/>)</nobr>
					</b>
				</font>
				<!--<xsl:value-of disable-output-escaping="yes" select="user:BeginTable()"/>-->
				<xsl:apply-templates select="Prop[@Name='ResultList']/Value[@ID]/Prop[@Type='TEResult']"/>
				<!--<xsl:value-of disable-output-escaping="yes" select="user:EndTable()"/>-->
				<!--<xsl:value-of disable-output-escaping="yes" select="user:AddEndingBlockQuotesForCurrentSequence()"/>-->
				<h5>
					<!--<font size="1">
      	    End Sequence: <xsl:value-of select="Prop[@Name='Sequence']/Value"/>
					</font>-->
				</h5>
				<xsl:value-of disable-output-escaping="yes" select="user:AddIndentEndTag()"/>
			</xsl:if>
		</xsl:if>
		<xsl:if test="Prop[@Name='ResultList']">
			<xsl:if test="Prop[@Name='ResultList'] and Prop[@HBound = '[]']">
				<br/>
			</xsl:if>
		</xsl:if>
		<!-- In case the resultList is deleted and does not exist in the stream -->
		<xsl:if test="not (Prop[@Name='ResultList'])">
			<font size="1">
				<br/>
            No Post Action Results Found
      </font>
		</xsl:if>
	</xsl:template>
	<xsl:template match="Prop[@Name='SequenceFile']">
		<xsl:if test="Value = ''">Unsaved Sequence File</xsl:if>
		<xsl:if test="Value != ''">
			<xsl:value-of select="Value"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="Value[@ID]/Prop[@Type='TEResult']">
	
<!--		<xsl:value-of disable-output-escaping="yes" select="user:ProcessCurrentBlockLevel(.)"/>-->
		<xsl:if test="Prop[@Name='TS']/Prop[@Name='NumLoops']">
			<xsl:value-of disable-output-escaping="yes" select="user:BeginLoopIndices(.)"/>
		</xsl:if>
		<xsl:if test="Prop[@Name='TS']/Prop[@Name='LoopIndex']">
			<xsl:value-of disable-output-escaping="yes" select="user:TestForStartLoopIndex()"/>
		</xsl:if>
		<!--<xsl:if test="user:GetAddTable() = '1'">
			<xsl:value-of disable-output-escaping="yes" select="user:BeginTable()"/>
		</xsl:if>-->
	<xsl:if test="Prop[@Name='Status']/Value = 'Passed' or Prop[@Name='Status']/Value = 'Failed' or Prop[@Name='Status']/Value = 'Terminated'">
		<tr>
		
		<!--<xsl:apply-templates select="Prop[@Name='Sequence']/Value"/>-->
		
			
			<td><font size="1">
					<xsl:value-of select="//Prop[@Name='StartDate']/Prop[@Name='ShortText']/Value"/>
					</font>			</td>
			<td><font size="1">
					<xsl:value-of select="//Prop[@Name='StartTime']/Prop[@Name='Text']/Value"/>
					</font></td>
			
			<xsl:apply-templates select="Prop[@Name='TS']/Prop[@Name='StepName']"/>
			
			<td></td>
			<font size="1">
				<xsl:apply-templates select="Prop[@Name='Status']"/>
			</font>
			
			<!--  If Status != Skipped adds the other Result Properties -->
			<xsl:if test="Prop[@Name='Status']/Value != 'Skipped'">
				<!--  If Status != terminated add the other Result Properties -->
				<!--<xsl:if test="Prop[@Name='Status']/Value != 'Terminated'">-->
					<!-- Look and for the following properties to find out if it is a Numeric Limit Step Type
					1. Step.Result.Numeric
					2. Step.Comp
					3. Step.Limits
					-->
					<xsl:if test="Prop[@Name='Numeric']">
						<xsl:if test="Prop[@Name='Comp']">
							<xsl:if test="Prop[@Name='Limits']">
								
								<td align="right">
									<xsl:if test="user:AreMeasurmentsIncluded()">
										<xsl:if test="(Prop[@Name='Numeric']/Value)">
											<font size="1">
												<nobr>
													<xsl:value-of select="user:ReturnLocalizedDecimalVal(Prop[@Name='Numeric']/Value)"/>
												</nobr>
											</font>
										</xsl:if>
										<xsl:if test="not(Prop[@Name='Numeric']/Value)">
											<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
										</xsl:if>
									</xsl:if>
									<xsl:if test="not(user:AreMeasurmentsIncluded())">
										<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
									</xsl:if>
								</td>
								
								<td align="center">
									<xsl:if test="not(Prop[@Name='Units']/Value)">
										<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
									</xsl:if>
									<xsl:if test="(Prop[@Name='Units']/Value)">
										<font size="1">
											<xsl:value-of disable-output-escaping="yes" select="user:RemoveWhiteSpace(Prop[@Name='Units']/Value)"/>
										</font>
									</xsl:if>
								</td>
								
								<td align="right">
									<xsl:if test="user:AreLimitsIncluded()">
										<xsl:if test="(Prop[@Name='Limits']/Prop[@Name='Low']/Value)">
											<font size="1">
												<nobr>
													<xsl:value-of select="user:ReturnLocalizedDecimalVal(Prop[@Name='Limits']/Prop[@Name='Low']/Value)"/>
												</nobr>
											</font>
										</xsl:if>
										<xsl:if test="not(Prop[@Name='Limits']/Prop[@Name='Low']/Value)">
											<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
										</xsl:if>
									</xsl:if>
									<xsl:if test="not(user:AreLimitsIncluded())">
										<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
									</xsl:if>
								</td>
								
								<td align="right">
									<xsl:if test="user:AreLimitsIncluded()">
										<xsl:if test="(Prop[@Name='Limits']/Prop[@Name='High']/Value)">
											<font size="1">
												<nobr>
													<xsl:value-of select="user:ReturnLocalizedDecimalVal(Prop[@Name='Limits']/Prop[@Name='High']/Value)"/>
												</nobr>
											</font>
										</xsl:if>
										<xsl:if test="not(Prop[@Name='Limits']/Prop[@Name='High']/Value)">
											<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
										</xsl:if>
									</xsl:if>
									<xsl:if test="not(user:AreLimitsIncluded())">
										<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
									</xsl:if>
								</td>
								
								<td align="center">
									<xsl:if test="not(Prop[@Name='Comp']/Value)">
										<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
									</xsl:if>
									<xsl:if test="(Prop[@Name='Comp']/Value)">
										<font size="1">
											<xsl:value-of disable-output-escaping="yes" select="user:GetComparisonTypeText(Prop[@Name='Comp']/Value)"/>
										</font>
									</xsl:if>
								</td>
							
							</xsl:if>
						</xsl:if>
					</xsl:if>
					<!--- Look for the following properties to find out if it is a String  Value Step Type
					1. Step.Result.String
					2. Step.Comp
					3. Step.Limits.String
          -->
					<xsl:if test="Prop[@Name='String']">
						<xsl:if test="Prop[@Name='Comp']">
							<xsl:if test="Prop[@Name='Limits']">
								<td align="center">
									<xsl:if test="user:AreMeasurmentsIncluded()">
										<font size="1">
											<xsl:if test="Prop[@Name='String']/Value = ''">''</xsl:if>
											<xsl:if test="(Prop[@Name='String']/Value !='')">
												<xsl:value-of disable-output-escaping="yes" select="user:RemoveWhiteSpace(Prop[@Name='String']/Value)"/>
											</xsl:if>
										</font>
									</xsl:if>
									<xsl:if test="not(user:AreMeasurmentsIncluded())">
										<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
									</xsl:if>
								</td>
								<!-- String Value Tests cannot have units -->
								<td>
									<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
								</td>
								<td align="center">
									<xsl:if test="user:AreLimitsIncluded()">
										<font size="1">
											<xsl:if test="Prop[@Name='Limits']/Prop[@Name='String']/Value=''">''</xsl:if>
											<xsl:if test="(Prop[@Name='Limits']/Prop[@Name='String']/Value != '')">
												<xsl:value-of disable-output-escaping="yes" select="user:RemoveWhiteSpace(Prop[@Name='Limits']/Prop[@Name='String']/Value)"/>
											</xsl:if>
										</font>
									</xsl:if>
									<xsl:if test="not(user:AreLimitsIncluded())">
										<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
									</xsl:if>
								</td>
								<!-- String Value Tests cannot have High Limits -->
								<td>
									<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
								</td>
								<td align="center">
									<xsl:if test="not(Prop[@Name='Comp']/Value)">
										<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
									</xsl:if>
									<xsl:if test="(Prop[@Name='Comp']/Value)">
										<font size="1">
											<xsl:value-of select="Prop[@Name='Comp']/Value"/>
										</font>
									</xsl:if>
								</td>
							</xsl:if>
						</xsl:if>
					</xsl:if>
					<!--- Look for the following properties to find out if it is a MultipleNumericLimit Step Type 
					1. Step.Result.Measurement
					2. Step.Result.Measurement is an Array of type NI_LimitMeasurement
          -->
					<!-- need to take care of AreMeasurmentIncluded case ???-->
					<xsl:if test="Prop[@Name='Measurement']">
						<xsl:if test="Prop/ArrayElementPrototype[@TypeName='NI_LimitMeasurement']">
							<td colspan="5">
								<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
							</td>
<!--						<tr valign="top">
								<td>
									<font size="1">
										<xsl:value-of disable-output-escaping="yes" select="user:GetStdIndentation()"/>
						
                  </font>
								</td>
								<td colspan="6">
									<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
								</td>
							</tr>
-->
							<xsl:apply-templates select="Prop[@Name='Measurement']/Value[@ID]"/>
						</xsl:if>
					</xsl:if>
					<!-- All the remaining Step Types -->
					<!--- Look for the following properties to find out if it is a Pass Fail Step Type
					1. Step.Result.PassFail
          -->
					<xsl:if test="Prop[@Name='PassFail']">
						<td>
							<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
						</td>
						<td>
							<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
						</td>
						<td>
							<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
						</td>
						<td>
							<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
						</td>
						<td>
							<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
						</td>
					</xsl:if>
					<!-- handle formatting if is Action Test-->
					<xsl:if test="Prop[@Name='Status']/Value = 'Done'">
						<xsl:if test="not(Prop[@Name='TS']/Prop[@Name='StepType']/Value = 'SequenceCall')">
							<xsl:if test="not(Prop[@Name = 'PassFail'])">
								<td>
									<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
								</td>
								<td>
									<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
								</td>
								<td>
									<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
								</td>
								<td>
									<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
								</td>
								<td>
									<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
								</td>
							</xsl:if>
						</xsl:if>
					</xsl:if>
					<xsl:if test="Prop[@Name='Status']/Value = 'Error'">
						<!-- Make sure that it is not a numeric limit step -->
						<xsl:if test="not(Prop[@Name='Numeric'])">
							<xsl:if test="not(Prop[@Name='Comp'])">
								<xsl:if test="not(Prop[@Name='Limits'])">
									<!-- Make sure that it is not a string value step -->
									<xsl:if test="not(Prop[@Name='String'])">
										<!-- Make sure that it is not a PassFail step -->
										<xsl:if test="not(Prop[@Name='PassFail'])">
											<!-- Make sure that it is not a sequence call step -->
											<xsl:if test="not(Prop[@Name='TS']/Prop[@Name='StepType']/Value = 'SequenceCall')">
												<!-- Make sure that it is not a Multi Numeric limit step -->
												<xsl:if test="not(Prop/ArrayElementPrototype[@TypeName='NI_LimitMeasurement'])">
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
												</xsl:if>
											</xsl:if>
										</xsl:if>
									</xsl:if>
								</xsl:if>
							</xsl:if>
						</xsl:if>
					</xsl:if>
					<!-- Take care of case when status is something else -->
					<xsl:if test="Prop[@Name='Status']/Value != 'Passed'">
						<xsl:if test="Prop[@Name='Status']/Value != 'Failed'">
							<xsl:if test="Prop[@Name='Status']/Value != 'Done'">
								<xsl:if test="Prop[@Name='Status']/Value != 'Error'">
									<xsl:if test="Prop[@Name='Status']/Value != 'Running'">
										<!-- Make sure that it is not a numeric limit step -->
										<xsl:if test="not(Prop[@Name='Numeric'])">
											<xsl:if test="not(Prop[@Name='Comp'])">
												<xsl:if test="not(Prop[@Name='Limits'])">
													<!-- Make sure that it is not a string value step -->
													<xsl:if test="not(Prop[@Name='String'])">
														<!-- Make sure that it is not a passFail  step -->
														<xsl:if test="not(Prop[@Name='PassFail'])">
															<!-- Make sure that it is not a sequence call step -->
															<xsl:if test="not(Prop[@Name='TS']/Prop[@Name='StepType']/Value = 'SequenceCall')">
																<!-- Make sure that it is not a Multi Numeric limit step -->
																<xsl:if test="not(Prop/ArrayElementPrototype[@TypeName='NI_LimitMeasurement'])">
																	<td>
																		<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
																	</td>
																	<td>
																		<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
																	</td>
																	<td>
																		<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
																	</td>
																	<td>
																		<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
																	</td>
																	<td>
																		<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
																	</td>
																</xsl:if>
															</xsl:if>
														</xsl:if>
													</xsl:if>
												</xsl:if>
											</xsl:if>
										</xsl:if>
									</xsl:if>
								</xsl:if>
							</xsl:if>
						</xsl:if>
					</xsl:if>
					<!-- Take care of cases when it is a action step and it is looping-->
					<xsl:if test="Prop[@Name='Status']/Value = 'Passed'">
						<!-- Make sure that it is not a numeric limit step -->
						<xsl:if test="not(Prop[@Name='Numeric'])">
							<xsl:if test="not(Prop[@Name='Comp'])">
								<xsl:if test="not(Prop[@Name='Limits'])">
									<!-- Make sure that it is not a string value step -->
									<xsl:if test="not(Prop[@Name='String'])">
										<!-- Make sure that it is not a passFail step -->
										<xsl:if test="not(Prop[@Name='PassFail'])">
											<!-- Make sure that it is not a sequence call step -->
											<xsl:if test="not(Prop[@Name='TS']/Prop[@Name='StepType']/Value = 'SequenceCall')">
												<!-- Make sure that it is not a Multi Numeric limit step -->
												<xsl:if test="not(Prop/ArrayElementPrototype[@TypeName='NI_LimitMeasurement'])">
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
												</xsl:if>
											</xsl:if>
										</xsl:if>
									</xsl:if>
								</xsl:if>
							</xsl:if>
						</xsl:if>
					</xsl:if>
					<!-- Take care of cases when it is a action step and it is looping-->
					<xsl:if test="Prop[@Name='Status']/Value = 'Failed'">
						<!-- Make sure that it is not a numeric limit step -->
						<xsl:if test="not(Prop[@Name='Numeric'])">
							<xsl:if test="not(Prop[@Name='Comp'])">
								<xsl:if test="not(Prop[@Name='Limits'])">
									<!-- Make sure that it is not a string value step -->
									<xsl:if test="not(Prop[@Name='String'])">
										<!-- Make sure that it is not a PassFail step -->
										<xsl:if test="not(Prop[@Name='PassFail'])">
											<!-- Make sure that it is not a sequence call step -->
											<xsl:if test="not(Prop[@Name='TS']/Prop[@Name='StepType']/Value = 'SequenceCall')">
												<!-- Make sure that it is not a Multi Numeric limit step -->
												<xsl:if test="not(Prop/ArrayElementPrototype[@TypeName='NI_LimitMeasurement'])">
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
												</xsl:if>
											</xsl:if>
										</xsl:if>
									</xsl:if>
								</xsl:if>
							</xsl:if>
						</xsl:if>
					</xsl:if>
					<!-- Take care of cases when it is a step is running -->
					<xsl:if test="Prop[@Name='Status']/Value = 'Running'">
						<!-- Make sure that it is not a numeric limit step -->
						<xsl:if test="not(Prop[@Name='Numeric'])">
							<xsl:if test="not(Prop[@Name='Comp'])">
								<xsl:if test="not(Prop[@Name='Limits'])">
									<!-- Make sure that it is not a string value step -->
									<xsl:if test="not(Prop[@Name='String'])">
										<!-- Make sure that it is not a PassFail step -->
										<xsl:if test="not(Prop[@Name='PassFail'])">
											<!-- Make sure that it is not a sequence call step -->
											<xsl:if test="not(Prop[@Name='TS']/Prop[@Name='StepType']/Value = 'SequenceCall')">
												<!-- Make sure that it is not a Multi Numeric limit step -->
												<xsl:if test="not(Prop/ArrayElementPrototype[@TypeName='NI_LimitMeasurement'])">
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
													<td>
														<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
													</td>
												</xsl:if>
											</xsl:if>
										</xsl:if>
									</xsl:if>
								</xsl:if>
							</xsl:if>
						</xsl:if>
					</xsl:if>
					<!-- correct formatting for SequenceCall Steps -->
					<xsl:if test="Prop[@Name='TS']/Prop[@Name='StepType']/Value = 'SequenceCall'">
						<td>
							<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
						</td>
						<td>
							<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
						</td>
						<td>
							<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
						</td>
						<td>
							<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
						</td>
						<td>
							<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
						</td>
					</xsl:if>
					<xsl:apply-templates select="Prop[@Name='TS']/Prop[@Name='NumLoops']"/>
					<xsl:apply-templates select="Prop[@Name='TS']/Prop[@Name='NumPassed']"/>
					<xsl:apply-templates select="Prop[@Name='TS']/Prop[@Name='NumFailed']"/>
					<xsl:apply-templates select="Prop[@Name='TS']/Prop[@Name='EndingLoopIndex']"/>
					<xsl:apply-templates select="Prop[@Name='TS']/Prop[@Name='InteractiveExeNum']"/>
					<xsl:apply-templates select="Prop[@Name='TS']/Prop[@Name='Server']"/>
					<!--<xsl:value-of disable-output-escaping="yes" select="user:PutFlaggedValuesInReport(Prop[@Flags], '', 0, 1)"/>-->
					<xsl:if test="Prop[@Name='Status']/Value = 'Error'">
						<xsl:apply-templates select="Prop[@Name='Error']"/>
					</xsl:if>
					
					<!-- If terminated in sequence call -->
					<!-- If you change this code, duplicate code below -->
					<xsl:if test="Prop[@Name='TS']/Prop[@Name='SequenceCall']/Prop[@Name='ResultList'] and Prop[@Name='TS']/Prop[@Name='SequenceCall']/Prop[@HBound != '[]']">
						<!--<xsl:value-of disable-output-escaping="yes" select="user:EndTable()"/>-->
						<xsl:value-of disable-output-escaping="yes" select="user:SetResultLevel(user:GetResultLevel()+1)"/>
						<xsl:value-of select="user:StoreCurrentLoopingLevel()"/>
						<xsl:apply-templates select="Prop[@Name='TS']/Prop[@Name='SequenceCall']"/>
						<xsl:value-of disable-output-escaping="yes" select="user:SetBlockLevel(0)"/>
						<xsl:value-of select="user:RestoreLoopingLevel()"/>
						<xsl:value-of disable-output-escaping="yes" select="user:SetResultLevel(user:GetResultLevel()-1)"/>
						<xsl:value-of select="user:SetAddTable(1)"/>
					</xsl:if>
					<!-- Handle post Action results -->
					<!-- If you change this code, duplicate code below -->
					<xsl:if test="Prop[@Name='TS']/Prop[@Name='PostAction']/Prop[@Name='ResultList'] and Prop[@Name='TS']/Prop[@Name='PostAction']/Prop[@HBound != '[]']">
						<xsl:if test="user:GetAddTable() = '1'">
							<xsl:value-of disable-output-escaping="yes" select="user:EndTable()"/>
						</xsl:if>
						<xsl:value-of disable-output-escaping="yes" select="user:SetResultLevel(user:GetResultLevel()+1)"/>
						<xsl:value-of select="user:StoreCurrentLoopingLevel()"/>
						<xsl:apply-templates select="Prop[@Name='TS']/Prop[@Name='PostAction']"/>
						<xsl:value-of disable-output-escaping="yes" select="user:SetBlockLevel(0)"/>
						<xsl:value-of select="user:RestoreLoopingLevel()"/>
						<xsl:value-of disable-output-escaping="yes" select="user:SetResultLevel(user:GetResultLevel()-1)"/>
						<xsl:value-of select="user:SetAddTable(1)"/>
					</xsl:if>
					<!-- Step status not terminated  -->
				<!--</xsl:if>-->
				<!-- Step status not skipped -->
			</xsl:if>
			
			<xsl:if test="Prop[@Name='Status']/Value = 'Skipped'">
				<td>
					<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
				</td>
				<td>
					<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
				</td>
				<td>
					<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
				</td>
				<td>
					<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
				</td>
				<td>
					<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
				</td>
			</xsl:if>
			<xsl:if test="Prop[@Name='Status']/Value = 'Terminated'">
				<td>
					<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
				</td>
				<td>
					<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
				</td>
				<td>
					<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
				</td>
				<td>
					<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
				</td>
				<td>
					<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
				</td>
				<!-- If terminated in sequence call -->
				<!-- If you change this code, duplicate code above -->
				<!-- Handle post Action results -->
				<!-- If you change this code, duplicate code above -->
				<xsl:if test="Prop[@Name='TS']/Prop[@Name='PostAction']/Prop[@Name='ResultList'] and Prop[@Name='TS']/Prop[@Name='PostAction']/Prop[@HBound != '[]']">
					<xsl:if test="user:GetAddTable() = '1'">
						<xsl:value-of disable-output-escaping="yes" select="user:EndTable()"/>
					</xsl:if>
					<xsl:value-of disable-output-escaping="yes" select="user:SetResultLevel(user:GetResultLevel()+1)"/>
					<xsl:value-of select="user:StoreCurrentLoopingLevel()"/>
					<xsl:apply-templates select="Prop[@Name='TS']/Prop[@Name='PostAction']"/>
					<xsl:value-of disable-output-escaping="yes" select="user:SetBlockLevel(0)"/>
					<xsl:value-of select="user:RestoreLoopingLevel()"/>
					<xsl:value-of disable-output-escaping="yes" select="user:SetResultLevel(user:GetResultLevel()-1)"/>
					<!--<xsl:value-of select="user:SetAddTable(1)"/>-->
				</xsl:if>
			</xsl:if>
			<xsl:if test="Prop[@Name='TS']/Prop[@Name='LoopIndex']">
				<xsl:value-of disable-output-escaping="yes" select="user:TestForEndLoopIndex()"/>
			</xsl:if>
			</tr>
		</xsl:if>
	</xsl:template>
	
	
	
	<xsl:template match="Prop[@Name='StepName']">
		<xsl:if test="../../Prop[@Name='Status']/Value = 'Passed' or ../../Prop[@Name='Status']/Value = 'Failed'">
			
			<td><font size="1">
					<xsl:value-of select="../Prop[@Name='StepType']/Value"/>
					</font></td>
			
			<td><font size="1">
					<xsl:value-of select="//Prop[@Name='SerialNumber']/Value"/>
					</font></td>
			
			<xsl:if test="../Prop[@Name='StepType']/Value != 'SequenceCall'">
			<td><font size="1">
					<xsl:value-of select="../../../../../../Prop[@Name='StepName']/Value"/>
					</font>
			</td>
			</xsl:if>	
			
			 <td>
<font size="1">
 <xsl:if test="user:GetIsCriticalFailure(.) = 'True'">
 <a>
 <xsl:attribute name="name">
  ResultId 
  <xsl:value-of select="user:GetResultId(.)" /> 
  </xsl:attribute>
  <xsl:value-of disable-output-escaping="yes" select="user:GetInitialIndentation(.)" /> 
 <!--  Empty step name case 
  --> 
 <xsl:if test="Value=''">
  <xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()" /> 
  </xsl:if>
 <xsl:if test="Value != ''">
  <xsl:value-of disable-output-escaping="yes" select="user:RemoveWhiteSpace(Value)" /> 
  </xsl:if>
  <xsl:value-of select="user:GetLoopIndex(.)" /> 
  <xsl:value-of select="user:GetStepNameAddition(.)" /> 
  </a>
  </xsl:if>
 <xsl:if test="user:GetIsCriticalFailure(.) = ''">
  <xsl:value-of disable-output-escaping="yes" select="user:GetInitialIndentation(.)" /> 
 <!--  Empty step name case 
  --> 
 <xsl:if test="Value=''">
  <xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()" /> 
  </xsl:if>
 <xsl:if test="Value != ''">
  <xsl:value-of disable-output-escaping="yes" select="user:RemoveWhiteSpace(Value)" /> 
  </xsl:if>
  <xsl:value-of select="user:GetLoopIndex(.)" /> 
  <xsl:value-of select="user:GetStepNameAddition(.)" /> 
  </xsl:if>
  </font>
  </td>
  </xsl:if>
	</xsl:template>
	
	<xsl:template match="Prop[@Name='Measurement']/Value[@ID]">
		<!-- If there is no status then assume that you not have an measurement array-->
		<xsl:if test="*/Prop[@Name ='Status']">
			<tr>
				<td><font size="1">
					<xsl:value-of select="//Prop[@Name='StartDate']/Prop[@Name='ShortText']/Value"/>
					</font>			</td>
			<td><font size="1">
					<xsl:value-of select="//Prop[@Name='StartTime']/Prop[@Name='Text']/Value"/>
					</font></td>
			
			<td><font size="1">
					<xsl:value-of select="../../Prop[@Name='TS']/Prop[@Name='StepType']/Value"/>
					</font></td>
			
				<td><font size="1">
					<xsl:value-of select="//Prop[@Name='SerialNumber']/Value"/>
					</font></td>
				
				<td>	<font size="1">
					<xsl:value-of select="../../../../../../../Prop[@Name='TS']/Prop[@Name='StepName']/Value"/>
					</font></td>
				<td><font size="1">
					<xsl:value-of select="../../Prop[@Name='TS']/Prop[@Name='StepName']/Value"/>
					</font>
			</td>
			
			
				<td>
					<font size="1">
						<xsl:value-of disable-output-escaping="yes" select="user:GetIndent(2)"/>
						<xsl:apply-templates select="Prop"/>
					</font>
				</td>
				
				
				<td align="left">
					<font size="1">
						<xsl:if test="*/Prop[@Name ='Status']/Value = '' ">
							<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
						</xsl:if>
						<xsl:if test="*/Prop[@Name ='Status']/Value != ''">
							<xsl:attribute name="color"><xsl:value-of select="user:GetStatusColor(*/Prop[@Name='Status']/Value)"/></xsl:attribute>
							<xsl:value-of select="*/Prop[@Name='Status']/Value"/>
						</xsl:if>
					</font>
				</td>
				
				<td align="left" valign="topt">
					<xsl:if test="user:AreMeasurmentsIncluded()">
						<font size="1">
							<nobr>
								<xsl:value-of select="user:ReturnLocalizedDecimalVal(*/Prop[@Name='Data']/Value)"/>
							</nobr>
						</font>
					</xsl:if>
					<xsl:if test="not(user:AreMeasurmentsIncluded())">
						<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
					</xsl:if>
				</td>
				<td align="left">
					<xsl:if test="not(*/Prop[@Name='Units']/Value)">
						<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
					</xsl:if>
					<xsl:if test="(*/Prop[@Name='Units']/Value)">
						<font size="1">
							<xsl:value-of disable-output-escaping="yes" select="user:RemoveWhiteSpace(*/Prop[@Name='Units']/Value)"/>
						</font>
					</xsl:if>
				</td>
				<td align="left">
					<xsl:if test="user:AreLimitsIncluded()">
						<font size="1">
							<nobr>
								<xsl:value-of select="user:ReturnLocalizedDecimalVal(*/Prop[@Name='Limits']/Prop[@Name='Low']/Value)"/>
							</nobr>
						</font>
						<xsl:if test="not(*/Prop[@Name='Limits']/Prop[@Name='Low']/Value)">
							<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
						</xsl:if>
					</xsl:if>
					<xsl:if test="not(user:AreLimitsIncluded())">
						<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
					</xsl:if>
				</td>
				<td align="left">
					<xsl:if test="user:AreLimitsIncluded()">
						<font size="1">
							<nobr>
								<xsl:value-of select="user:ReturnLocalizedDecimalVal(*/Prop[@Name='Limits']/Prop[@Name='High']/Value)"/>
							</nobr>
						</font>
						<xsl:if test="not(*/Prop[@Name='Limits']/Prop[@Name='High']/Value)">
							<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
						</xsl:if>
					</xsl:if>
					<xsl:if test="not(user:AreLimitsIncluded())">
						<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
					</xsl:if>
				</td>
				<td align="left" >
					<font size="1">
						<xsl:value-of disable-output-escaping="yes" select="user:GetComparisonTypeText(*/Prop[@Name='Comp']/Value)"/>
					</font>
				</td>
				
			</tr>
		</xsl:if>
	</xsl:template>
	<xsl:template match="Prop">
		<xsl:value-of select="@Name"/>
	</xsl:template>
	<xsl:template match="Prop[@Name='Error']">
		<tr>
			<td valign="top" nowrap="nowrap">
				<font size="1">
					<xsl:attribute name="color"><xsl:value-of select="user:GetErrorColor()"/></xsl:attribute>
					<xsl:value-of disable-output-escaping="yes" select="user:GetStdIndentation()"/>
					Error Message: 
				</font>
			</td>
			<td valign="center" colspan="6">
				<font size="1">
					<xsl:attribute name="color"><xsl:value-of select="user:GetErrorColor()"/></xsl:attribute>
					<xsl:value-of disable-output-escaping="yes" select="user:RemoveIllegalCharacters(Prop[@Name='Msg'])"/>
					[Error Code: <xsl:value-of select="Prop[@Name='Code']/Value"/>]
				</font>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="Prop[@Name='InteractiveExeNum']">
		<tr>
			<td valign="center" nowrap="nowrap">
				<font size="1">
					<xsl:value-of disable-output-escaping="yes" select="user:GetStdIndentation()"/>
     			Interactive Execution #: 
				</font>
			</td>
			<td nowrap="nowrap" colspan="6">
				<font size="1">
					<xsl:value-of select="Value"/>
				</font>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="Prop[@Name='Server']">
		<tr>
			<td valign="center">
				<font size="1">
					<xsl:value-of disable-output-escaping="yes" select="user:GetStdIndentation()"/>
			   	Server:
			  </font>
			</td>
			<td nowrap="nowrap" colspan="6">
				<font size="1">
					<xsl:value-of select="Value"/>
				</font>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="Prop[@Name='NumLoops']">
		<tr>
			<td nowrap="nowrap">
				<font size="1">
					<xsl:value-of disable-output-escaping="yes" select="user:GetStdIndentation()"/>
     	   	Number of Loops: 
				</font>
			</td>
			<td nowrap="nowrap" colspan="6">
				<font size="1">
					<xsl:value-of select="Value"/>
				</font>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="Prop[@Name='NumPassed']">
		<tr>
			<td nowrap="nowrap">
				<font size="1">
					<xsl:value-of disable-output-escaping="yes" select="user:GetStdIndentation()"/>
        	Number of Passes: 
				</font>
			</td>
			<td nowrap="nowrap" colspan="6">
				<font size="1">
					<xsl:value-of select="Value"/>
				</font>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="Prop[@Name='NumFailed']">
		<tr>
			<td nowrap="nowrap">
				<font size="1">
					<xsl:value-of disable-output-escaping="yes" select="user:GetStdIndentation()"/>
          Number of Failures: 
		    </font>
			</td>
			<td nowrap="nowrap" colspan="6">
				<font size="1">
					<xsl:value-of select="Value"/>
				</font>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="Prop[@Name='EndingLoopIndex']">
		<tr>
			<td nowrap="nowrap">
				<font size="1">
					<xsl:value-of disable-output-escaping="yes" select="user:GetStdIndentation()"/>
        	Final Loop Index:
			  </font>
			</td>
			<td nowrap="nowrap" colspan="6">
				<font size="1">
					<xsl:value-of select="user:ReturnLocalizedDecimalVal(Value)"/>
				</font>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="Prop[@Name='CriticalFailureStack']">
		<xsl:if test="Value">
			<tbody>
				<tr>
					<td align="center">
						<font size="1">
							<b>Step</b>
						</font>
					</td>
					<td align="center">
						<font size="1">
							<b>Sequence</b>
						</font>
					</td>
					<td align="center">
						<font size="1">
							<b>Sequence File</b>
						</font>
					</td>
				</tr>
				<xsl:for-each select="Value">
					<xsl:sort select="@ID" order="descending"/>
					<tr>
						<td>
							<font size="1">
								<a xml:link="simple" inline="true">
									<xsl:attribute name="href">#ResultId<xsl:value-of select="Prop/Prop[@Name='ResultId']/Value"/></xsl:attribute>
									<xsl:value-of select="Prop/Prop[@Name='StepName']/Value"/>
								</a>
							</font>
						</td>
						<td>
							<font size="1">
								<xsl:value-of select="Prop/Prop[@Name='SequenceName']/Value"/>
							</font>
						</td>
						<td>
							<font size="1">
								<xsl:value-of select="Prop/Prop[@Name='SequenceFileName']/Value"/>
							</font>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</xsl:if>
	</xsl:template>
	<xsl:template match="BatchTable">
		<table border="1" cellpadding="2" cellspacing="0" rules="all" width="60%">
			<tr valign="top">
				<td nowrap="nowrap" align="center" width="10%">
					<font size="1">
						<b>Test Socket</b>
					</font>
				</td>
				<td nowrap="nowrap" align="center" width="25%">
					<font size="1">
						<b>UUT Serial Number</b>
					</font>
				</td>
				<td nowrap="nowrap" align="center" width="25%">
					<font size="1">
						<b>UUT Result</b>
					</font>
				</td>
			</tr>
			<xsl:apply-templates select="UUThref"/>
		</table>
	</xsl:template>
	<xsl:template match="UUThref">
		<tr align="center">
			<td>
				<font size="1">
					<xsl:value-of select="@SocketIndex"/>
				</font>
			</td>
			<td>
				<font size="1">
					<xsl:if test="@Anchor != ''">
						<a xml:link="simple" inline="true">
							<xsl:attribute name="href"><xsl:value-of select="user:GetLinkURL(.)"/>#<xsl:value-of select="@Anchor"/></xsl:attribute>
							<xsl:value-of select="@LinkName"/>
						</a>
					</xsl:if>
					<xsl:if test="@Anchor = ''">
						<xsl:value-of disable-output-escaping="yes" select="user:GetEmptyCellVal()"/>
					</xsl:if>
				</font>
			</td>
			<td>
				<font size="1">
					<xsl:attribute name="color"><xsl:value-of select="user:GetStatusColor(@UUTResult)"/></xsl:attribute>
					<xsl:value-of select="@UUTResult"/>
				</font>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="Prop[@Name='Status']">
		<xsl:if test="../Prop[@Name='TS']/Prop[@Name='StepType']/Value = 'SequenceCall'">
		<td></td> 
		</xsl:if>	
<!--		<td></td>-->

		<td valign="center" align="center">
			<font size="1">
				<xsl:if test="user:GetIsCriticalFailureFromStatus(.) = 'True' ">
					<xsl:attribute name="Color"><xsl:value-of select="user:GetStatusColor(Value)"/></xsl:attribute>
					<b>
						<xsl:value-of select="Value"/>
					</b>
				</xsl:if>
				<xsl:if test="user:GetIsCriticalFailureFromStatus(.) = ''">
					<xsl:attribute name="Color"><xsl:value-of select="user:GetStatusColor(Value)"/></xsl:attribute>
					<xsl:value-of select="Value"/>
				</xsl:if>
				
			</font>
		</td>
		
		
	</xsl:template>
	
</xsl:stylesheet>
