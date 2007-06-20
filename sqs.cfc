<cfcomponent output="false">

	<!---
	
		Amazon SQS CFC
		
		Copyright (c) 2007, Jeffrey Pratt

		All rights reserved.
		
		Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
		
			* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
			* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
			* Neither the name of Simplicity Group, LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
		
		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
		"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
		LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
		A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
		CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
		EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
		PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
		PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
		LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
		NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
		SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	
	--->
	
	<!---
	
		KNOWN ISSUES:
		
		* addGrant throws a "Service Unavailable" exception (as of 20 June 2007)
	
	--->

	<cfset This.sqsVersion = "2007-05-01"/>
	<cfset This.serviceUrl = "http://queue.amazonaws.com"/>

	<cffunction name="init" output="false" returntype="sqs" hint="Constructor">
		<cfargument name="awsAccessKeyId" type="string" required="true"/>
		<cfargument name="secretAccessKey" type="string" required="true"/>
		
		<cfset This.awsAccessKeyId = Arguments.awsAccessKeyId/>
		<cfset This.secretAccessKey = Arguments.secretAccessKey/>
		
		<cfreturn This/>
	</cffunction>
	
	<cffunction name="addGrant" output="true" returntype="void"> <!--- TODO: Test --->
		<cfargument name="uri" type="string" required="true"/>
		<cfargument name="queueName" type="string" required="true"/>
		<cfargument name="permission" type="string" required="true"/>
		<cfargument name="granteeEmailAddress" type="string" required="false"/>
		<cfargument name="granteeId" type="string" required="false"/>
		
		<cfset var Function = StructNew()/>
		
		<cfset Function.dateTimeString = zuluDateTimeFormat(Now())/>
		
		<cfif IsDefined("Arguments.granteeEmailAddress")>
			<cfset Function.granteeEmailAddressPair = "Grantee.EmailAddress#Arguments.granteeEmailAddress#"/>
		<cfelse>
			<cfset Function.granteeEmailAddressPair = ""/>
		</cfif>
		
		<cfif IsDefined("Arguments.granteeId")>
			<cfset Function.granteeIdPair = "Grantee.Id#Arguments.granteeId#"/>
		<cfelse>
			<cfset Function.granteeIdPair = ""/>
		</cfif>
		
		<!--- Build signature string --->
		
		<cfset Function.fixedData = "ActionAddGrant" & 
									"AWSAccessKeyId#This.awsAccessKeyId#" &
									Function.granteeEmailAddressPair &
									Function.granteeIdPair &
									"Permission#Arguments.permission#" &
									"QueueName#Arguments.queueName#" &
									"SignatureVersion1" &
									"Timestamp#Function.dateTimeString#" &
									"Version#This.sqsVersion#"/>
		
		<cfset Function.signature = createSignature(Function.fixedData)/>
		
		<cfhttp method="GET" url="#Arguments.uri#" charset="UTF-8">
			<cfhttpparam type="url" name="Action" value="AddGrant"/>
			<cfhttpparam type="url" name="AWSAccessKeyId" value="#This.awsAccessKeyId#"/>
			<cfif IsDefined("Arguments.granteeEmailAddress")>
				<cfhttpparam type="url" name="Grantee.EmailAddress" value="#Arguments.granteeEmailAddress#"/>
			</cfif>
			<cfif IsDefined("Arguments.granteeId")>
				<cfhttpparam type="url" name="Grantee.Id" value="#Arguments.granteeId#"/>
			</cfif>
			<cfhttpparam type="url" name="Permission" value="#Arguments.permission#"/>
			<cfhttpparam type="url" name="QueueName" value="#Arguments.queueName#"/>
			<cfhttpparam type="url" name="Signature" value="#Function.signature#"/>
			<cfhttpparam type="url" name="SignatureVersion" value="1"/>
			<cfhttpparam type="url" name="Timestamp" value="#Function.dateTimeString#"/>
			<cfhttpparam type="url" name="Version" value="#This.sqsVersion#"/>
		</cfhttp>
		
		<cfif CFHTTP.ResponseHeader.Status_Code neq 200>
			<cfinvoke method="handleErrors"
				content="#CFHTTP.FileContent#"
			/>
		</cfif>
	</cffunction>
	
	<cffunction name="changeMessageVisibility" output="true" returntype="void"> <!--- TODO: Test --->
		<cfargument name="uri" type="string" required="true"/>
		<cfargument name="messageId" type="string" required="true"/>
		<cfargument name="visibilityTimeout" type="numeric" required="true"/>
		
		<cfset var Function = StructNew()/>
		
		<cfset Function.dateTimeString = zuluDateTimeFormat(Now())/>
		
		<!--- Build signature string --->
		
		<cfset Function.fixedData = "ActionChangeMessageVisibility" &
									"AWSAccessKeyId#This.awsAccessKeyId#" &
									"MessageId#Arguments.messageId#" &
									"SignatureVersion1" &
									"Timestamp#Function.dateTimeString#" &
									"Version#This.sqsVersion#" &
									"VisibilityTimeout#Arguments.visibilityTimeout#"/>

		<cfset Function.signature = createSignature(Function.fixedData)/>
		
		<cfhttp method="GET" url="#Arguments.uri#" charset="UTF-8">
			<cfhttpparam type="url" name="Action" value="ChangeMessageVisibility"/>
			<cfhttpparam type="url" name="AWSAccessKeyId" value="#This.awsAccessKeyId#"/>
			<cfhttpparam type="url" name="MessageId" value="#Arguments.messageId#"/>
			<cfhttpparam type="url" name="Signature" value="#Function.signature#"/>
			<cfhttpparam type="url" name="SignatureVersion" value="1"/>
			<cfhttpparam type="url" name="Timestamp" value="#Function.dateTimeString#"/>
			<cfhttpparam type="url" name="Version" value="#This.sqsVersion#"/>
			<cfhttpparam type="url" name="VisibilityTimeout" value="#Arguments.visibilityTimeout#"/>
		</cfhttp>
		
		<cfif CFHTTP.ResponseHeader.Status_Code neq 200>
			<cfinvoke method="handleErrors"
				content="#CFHTTP.FileContent#"
			/>
		</cfif>
	</cffunction>
	
	<cffunction name="createSignature" output="false" returntype="string">
		<cfargument name="fixedData" type="string" required="true"/>
		
		<!--- Hash signature string --->
											
		<cfinvoke component="HMAC" method="hmac" returnvariable="Function.digest">
			<cfinvokeargument name="hash_function" value="sha1"/>
			<cfinvokeargument name="data" value="#Arguments.fixedData#"/>
			<cfinvokeargument name="key" value="#This.secretAccessKey#"/>
		</cfinvoke>
		
		<!--- Create signature --->
		
		<cfreturn ToBase64(hexToBin(Function.digest))/>
	</cffunction>
	
	<cffunction name="createQueue" output="true" returntype="string">
		<cfargument name="queueName" type="string" required="true"/>
		<cfargument name="defaultVisibilityTimeout" type="numeric" required="false"/>
		
		<cfset var Function = StructNew()/> <!--- create a varred "Function" scope for all function variables --->
		
		<cfset Function.dateTimeString = zuluDateTimeFormat(Now())/>
		
		<cfif IsDefined("Arguments.defaultVisibilityTimeout")>
			<cfset Function.defaultVisibilityTimeoutPair = "DefaultVisibilityTimeout#Arguments.defaultVisibilityTimeout#"/>
		<cfelse>
			<cfset Function.defaultVisibilityTimeoutPair = ""/>
		</cfif>
		
		<!--- Build signature string --->
		
		<cfset Function.fixedData = "ActionCreateQueue" &
									"AWSAccessKeyId#This.awsAccessKeyId#" &
									Function.defaultVisibilityTimeoutPair &
									"QueueName#Arguments.queueName#" &
									"SignatureVersion1" &
									"Timestamp#Function.dateTimeString#" &
									"Version#This.sqsVersion#"/>
		
		<cfset Function.signature = createSignature(Function.fixedData)/>
		
		<cfhttp method="GET" url="#This.serviceUrl#" charset="UTF-8">
			<cfhttpparam type="url" name="Action" value="CreateQueue"/>
			<cfhttpparam type="url" name="AWSAccessKeyId" value="#This.awsAccessKeyId#"/>
			<cfif IsDefined("Arguments.defaultVisibilityTimeout")>
				<cfhttpparam type="url" name="DefaultVisibilityTimeout" value="#Arguments.defaultVisibilityTimeout#"/>
			</cfif>
			<cfhttpparam type="url" name="QueueName" value="#Arguments.queueName#"/>
			<cfhttpparam type="url" name="Signature" value="#Function.signature#"/>
			<cfhttpparam type="url" name="SignatureVersion" value="1"/>
			<cfhttpparam type="url" name="Timestamp" value="#Function.dateTimeString#"/>
			<cfhttpparam type="url" name="Version" value="#This.sqsVersion#"/>
		</cfhttp>
		
		
		<cfif CFHTTP.ResponseHeader.Status_Code neq 200>
			<cfinvoke method="handleErrors"
				content="#CFHTTP.FileContent#"
			/>
		<cfelse>
			<cfset Function.queue = XmlSearch(CFHTTP.FileContent, "//:QueueUrl")/>		
			<cfreturn Function.queue[1].XmlText/>
		</cfif>
	</cffunction>
	
	<cffunction name="deleteMessage" output="true" returntype="void">
		<cfargument name="uri" type="string" required="true"/>
		<cfargument name="messageId" type="string" required="true"/>
		
		<cfset var Function = StructNew()/>
		
		<cfset Function.dateTimeString = zuluDateTimeFormat(Now())/>
		
		<!--- Build signature string --->
		
		<cfset Function.fixedData = "ActionDeleteMessage" &
									"AWSAccessKeyId#This.awsAccessKeyId#" &
									"MessageId#Arguments.messageid#" &
									"SignatureVersion1" &
									"Timestamp#Function.dateTimeString#" &
									"Version#This.sqsVersion#"/>

		<cfset Function.signature = createSignature(Function.fixedData)/>
		
		<cfhttp method="GET" url="#Arguments.uri#" charset="UTF-8">
			<cfhttpparam type="url" name="Action" value="DeleteMessage"/>
			<cfhttpparam type="url" name="AWSAccessKeyId" value="#This.awsAccessKeyId#"/>
			<cfhttpparam type="url" name="MessageId" value="#Arguments.messageId#"/>
			<cfhttpparam type="url" name="Signature" value="#Function.signature#"/>
			<cfhttpparam type="url" name="SignatureVersion" value="1"/>
			<cfhttpparam type="url" name="Timestamp" value="#Function.dateTimeString#"/>
			<cfhttpparam type="url" name="Version" value="#This.sqsVersion#"/>
		</cfhttp>
		
		<cfif CFHTTP.ResponseHeader.Status_Code neq 200>
			<cfinvoke method="handleErrors"
				content="#CFHTTP.FileContent#"
			/>
		</cfif>
	</cffunction>
	
	<cffunction name="deleteQueue" output="true" returntype="void">
		<cfargument name="uri" type="string" required="true"/>
		<cfargument name="forceDeletion" type="boolean" required="false" default="false"/>
		
		<cfset var Function = StructNew()/>
		
		<cfset Function.dateTimeString = zuluDateTimeFormat(Now())/>
		
		<!--- Build signature string --->
		
		<cfset Function.fixedData = "ActionDeleteQueue" &
									"AWSAccessKeyId#This.awsAccessKeyId#" &
									"ForceDeletion#Arguments.forceDeletion#" &
									"SignatureVersion1" &
									"Timestamp#Function.dateTimeString#" &
									"Version#This.sqsVersion#"/>
		
		<cfset Function.signature = createSignature(Function.fixedData)/>
		
		<cfhttp method="GET" url="#Arguments.uri#" charset="UTF-8">
			<cfhttpparam type="url" name="Action" value="DeleteQueue"/>
			<cfhttpparam type="url" name="AWSAccessKeyId" value="#This.awsAccessKeyId#"/>
			<cfhttpparam type="url" name="ForceDeletion" value="#Arguments.forceDeletion#"/>
			<cfhttpparam type="url" name="Signature" value="#Function.signature#"/>
			<cfhttpparam type="url" name="SignatureVersion" value="1"/>
			<cfhttpparam type="url" name="Timestamp" value="#Function.dateTimeString#"/>
			<cfhttpparam type="url" name="Version" value="#This.sqsVersion#"/>
		</cfhttp>
		
		<cfif CFHTTP.ResponseHeader.Status_Code neq 200>
			<cfinvoke method="handleErrors"
				content="#CFHTTP.FileContent#"
			/>
		</cfif>
	</cffunction>
	
	<cffunction name="getQueueAttributes" output="false" returntype="struct">
		<cfargument name="uri" type="string" required="true"/>
		<cfargument name="attribute" type="string" required="true"/>
		
		<cfset var Function = StructNew()/>
		
		<cfset Function.dateTimeString = zuluDateTimeFormat(Now())/>
		
		<cfset Function.fixedData = "ActionGetQueueAttributes" &
									"Attribute#Arguments.attribute#" &
									"AWSAccessKeyId#This.awsAccessKeyId#" &
									"SignatureVersion1" &
									"Timestamp#Function.dateTimeString#" &
									"Version#This.sqsVersion#"/>

		<cfset Function.signature = createSignature(Function.fixedData)/>
		
		<cfhttp method="GET" url="#Arguments.uri#" charset="UTF-8">
			<cfhttpparam type="url" name="Action" value="GetQueueAttributes"/>
			<cfhttpparam type="url" name="Attribute" value="#Arguments.attribute#"/>
			<cfhttpparam type="url" name="AWSAccessKeyId" value="#This.awsAccessKeyId#"/>
			<cfhttpparam type="url" name="Signature" value="#Function.signature#"/>
			<cfhttpparam type="url" name="SignatureVersion" value="1"/>
			<cfhttpparam type="url" name="Timestamp" value="#Function.dateTimeString#"/>
			<cfhttpparam type="url" name="Version" value="#This.sqsVersion#"/>
		</cfhttp>
		
		
		<cfif CFHTTP.ResponseHeader.Status_Code neq 200>
			<cfinvoke method="handleErrors"
				content="#CFHTTP.FileContent#"
			/>
		<cfelse>
			<cfset Function.attributedValues = XmlSearch(CFHTTP.FileContent, "//:AttributedValue")/>
			<cfset Function.attributedValuesCount = ArrayLen(Function.attributedValues)/>
			
			<cfset Function.attributes = StructNew()/>
			
			<cfloop index="i" from="1" to="#Function.attributedValuesCount#">
				<cfset Function.attributes[Function.attributedValues[i].Attribute.XmlText] = Function.attributedValues[i].Value.XmlText/>
			</cfloop>
			
			<cfreturn Function.attributes/>
		</cfif>
	</cffunction>
	
	<cffunction name="handleErrors" output="true" returntype="void" access="private">
		<cfargument name="content" type="string" required="true"/>

		<cfset var Function = StructNew()/>
		
		<cfif Arguments.content is "Connection failure">	
			<cfthrow type="ConnectionFailureException" 
				message="Connection failure." 
				detail="No connection could be made to ""#Arguments.uri#""."
			/>
		<cfelse>
			<!--- Get first error --->
			
			<cfset Function.content = XmlSearch(Arguments.content, "//Response/Errors/Error")/>
	
			<cfset Function.errorCode = Function.content[1].Code.XmlText/>
			<cfset Function.errorMessage = Function.content[1].Message.XmlText/>
			
			<!--- Create CF exception from error --->
			
			<cfthrow type="#Function.errorCode#" 
				message="#Function.errorCode#" 
				detail="#Function.errorMessage#"
			/>
		</cfif>
	</cffunction>
	
	<cffunction name="hexToBin" output="false" access="private">
		<cfargument name="inputString" type="string" required="true" hint="The hexadecimal string to be written.">
	
		<cfset var outStream = CreateObject("java", "java.io.ByteArrayOutputStream").init()>
		<cfset var inputLength = Len(arguments.inputString)>
		<cfset var outputString = "">
		<cfset var i = 0>
		<cfset var ch = "">
	
		<cfif inputLength mod 2 neq 0>
			<cfset arguments.inputString = "0" & inputString>
		</cfif>
	
		<cfloop from="1" to="#inputLength#" index="i" step="2">
			<cfset ch = Mid(inputString, i, 2)>
			<cfset outStream.write(javacast("int", InputBaseN(ch, 16)))>
		</cfloop>
	
		<cfset outStream.flush()>
		<cfset outStream.close()>
	
		<cfreturn outStream.toByteArray()>
	</cffunction>
	
	<cffunction name="listGrants" output="true" returntype="array">
		<cfargument name="uri" type="string" required="true"/>
		<cfargument name="queueName" type="string" required="true"/>
		<cfargument name="granteeEmailAddress" type="string" required="false"/>
		<cfargument name="granteeId" type="string" required="false"/>
		<cfargument name="permission" type="string" required="false"/>
		
		<cfset var Function = StructNew()/>
		
		<cfset Function.dateTimeString = zuluDateTimeFormat(Now())/>
		
		<cfif IsDefined("Arguments.granteeEmailAddress")>
			<cfset Function.granteeEmailAddressPair = "Grantee.EmailAddress#Arguments.granteeEmailAddress#"/>
		<cfelse>
			<cfset Function.granteeEmailAddressPair = ""/>
		</cfif>
		
		<cfif IsDefined("Arguments.granteeId")>
			<cfset Function.granteeIdPair = "Grantee.Id#Arguments.granteeId#"/>
		<cfelse>
			<cfset Function.granteeIdPair = ""/>
		</cfif>
		
		<cfif IsDefined("Arguments.permission")>
			<cfset Function.permissionPair = "Permission#Arguments.permission#"/>
		<cfelse>
			<cfset Function.permissionPair = ""/>
		</cfif>
		
		<!--- Build signature string --->
		
		<cfset Function.fixedData = "ActionListGrants" &
									"AWSAccessKeyId#This.awsAccessKeyId#" &
									Function.granteeEmailAddressPair &
									Function.granteeIdPair &
									Function.permissionPair &
									"QueueName#Arguments.queueName#" &
									"SignatureVersion1" &
									"Timestamp#Function.dateTimeString#" &
									"Version#This.sqsVersion#"/>
		
		<cfset Function.signature = createSignature(Function.fixedData)/>
		
		<cfhttp method="GET" url="#Arguments.uri#" charset="UTF-8">
			<cfhttpparam type="url" name="Action" value="ListGrants"/>
			<cfhttpparam type="url" name="AWSAccessKeyId" value="#This.awsAccessKeyId#"/>
			<cfif IsDefined("Arguments.granteeEmailAddress")>
				<cfhttpparam type="url" name="Grantee.EmailAddress" value="#Arguments.granteeEmailAddress#"/>
			</cfif>
			<cfif IsDefined("Arguments.granteeId")>
				<cfhttpparam type="url" name="Grantee.Id" value="#Arguments.granteeId#"/>
			</cfif>
			<cfif IsDefined("Arguments.permission")>
				<cfhttpparam type="url" name="Permission" value="#Arguments.permission#"/>
			</cfif>
			<cfhttpparam type="url" name="QueueName" value="#Arguments.queueName#"/>
			<cfhttpparam type="url" name="Signature" value="#Function.signature#"/>
			<cfhttpparam type="url" name="SignatureVersion" value="1"/>
			<cfhttpparam type="url" name="Timestamp" value="#Function.dateTimeString#"/>
			<cfhttpparam type="url" name="Version" value="#This.sqsVersion#"/>
		</cfhttp>
		
		<cfif CFHTTP.ResponseHeader.Status_Code neq 200>
			<cfinvoke method="handleErrors"
				content="#CFHTTP.FileContent#"
			/>
		<cfelse>		
			<cfset Function.grantLists = XmlSearch(CFHTTP.FileContent, "//:GrantList")/>
			<cfset Function.grantListsCount = ArrayLen(Function.grantLists)/>
			
			<cfset Function.grants = ArrayNew(1)/>
			
			<cfloop index="i" from="1" to="#Function.grantListsCount#">
				<cfset Function.grants[i] = StructNew()/>
				<cfset Function.grants[i].DisplayName = Function.grantLists[i].Grantee.DisplayName.XmlText/>
				<cfset Function.grants[i].ID = Function.grantLists[i].Grantee.ID.XmlText/>
				<cfset Function.grants[i].Permission = Function.grantLists[i].Permission.XmlText/>
			</cfloop>
			
			<cfreturn Function.grants/>
		</cfif>
	</cffunction>
	
	<cffunction name="listQueues" output="true" returntype="array">
		<cfargument name="queueNamePrefix" type="string" required="false"/>
		
		<cfset var Function = StructNew()/>
		
		<cfset Function.dateTimeString = zuluDateTimeFormat(Now())/>
		
		<cfif IsDefined("Arguments.queueNamePrefix")>
			<cfset Function.queueNamePrefixPair = "QueueNamePrefix#Arguments.queueNamePrefix#"/>
		<cfelse>
			<cfset Function.queueNamePrefixPair = ""/>
		</cfif>
		
		<!--- Build signature string --->
		
		<cfset Function.fixedData = "ActionListQueues" &
        							"AWSAccessKeyId#This.awsAccessKeyId#" &
									Function.queueNamePrefixPair &
									"SignatureVersion1" &
									"Timestamp#Function.dateTimeString#" &
									"Version#This.sqsVersion#"/>
		
		<cfset Function.signature = createSignature(Function.fixedData)/>
		
		<cfhttp method="GET" url="#This.serviceUrl#" charset="UTF-8">
			<cfhttpparam type="url" name="Action" value="ListQueues"/>
			<cfhttpparam type="url" name="AWSAccessKeyId" value="#This.awsAccessKeyId#"/>
			<cfif IsDefined("Arguments.queueNamePrefix")>
				<cfhttpparam type="url" name="QueueNamePrefix" value="#Arguments.queueNamePrefix#"/>
			</cfif>
			<cfhttpparam type="url" name="Signature" value="#Function.signature#"/>
			<cfhttpparam type="url" name="SignatureVersion" value="1"/>
			<cfhttpparam type="url" name="Timestamp" value="#Function.dateTimeString#"/>
			<cfhttpparam type="url" name="Version" value="#This.sqsVersion#"/>
		</cfhttp>
		
		<cfif CFHTTP.ResponseHeader.Status_Code neq 200>
			<cfinvoke method="handleErrors"
				content="#CFHTTP.FileContent#"
			/>
		<cfelse>		
			<cfset Function.queueUrls = XmlSearch(CFHTTP.FileContent, "//:QueueUrl")/>
			
			<cfset Function.queueUrlsCount = ArrayLen(Function.queueUrls)/>
			
			<cfset Function.queues = ArrayNew(1)/>
			<cfloop index="i" from="1" to="#Function.queueUrlsCount#">
				<cfset ArrayAppend(Function.queues, Function.queueUrls[i].XmlText)/>
			</cfloop>
			
			<cfreturn Function.queues/>
		</cfif>
	</cffunction>
	
	<cffunction name="peekMessage" output="false" returntype="struct"> <!--- TODO: Test --->
		<cfargument name="uri" type="string" required="true"/>
		<cfargument name="messageId" type="string" required="true"/>
		
		<cfset var Function = StructNew()/>
		
		<cfset Function.dateTimeString = zuluDateTimeFormat(Now())/>
		
		<!--- Build signature string --->
		
		<cfset Function.fixedData = "ActionPeekMessage" &
									"AWSAccessKeyId#This.awsAccessKeyId#" &
									"MessageId#Arguments.messageId#" &
									"SignatureVersion1" &
									"Timestamp#Function.dateTimeString#" &
									"Version#This.sqsVersion#"/>
		
		<cfset Function.signature = createSignature(Function.fixedData)/>
		
		<cfhttp method="GET" url="#Arguments.uri#" charset="UTF-8">
			<cfhttpparam type="url" name="Action" value="PeekMessage"/>
			<cfhttpparam type="url" name="AWSAccessKeyId" value="#This.awsAccessKeyId#"/>
			<cfhttpparam type="url" name="MessageId" value="#Arguments.messageId#"/>
			<cfhttpparam type="url" name="Signature" value="#Function.signature#"/>
			<cfhttpparam type="url" name="SignatureVersion" value="1"/>
			<cfhttpparam type="url" name="Timestamp" value="#Function.dateTimeString#"/>
			<cfhttpparam type="url" name="Version" value="#This.sqsVersion#"/>
		</cfhttp>
		
		<cfif CFHTTP.ResponseHeader.Status_Code neq 200>
			<cfinvoke method="handleErrors"
				content="#CFHTTP.FileContent#"
			/>
		<cfelse>
			<cfset Function.messageNode = XmlSearch(CFHTTP.FileContent, "//:Message")/>
			
			<cfset Function.message = StructNew()/>
			
			<cfset Function.message.ID = Function.messageNode[1].MessageId.XmlText/>
			<cfset Function.message.body = Function.messageNode[1].MessageBody.XmlText/>
			
			<cfreturn Function.message/>
		</cfif>
	</cffunction>
	
	<cffunction name="receiveMessage" output="false" returntype="array">
		<cfargument name="uri" type="string" required="true"/>
		<cfargument name="numberOfMessages" type="numeric" required="false"/>
		<cfargument name="visibilityTimeout" type="numeric" required="false"/>
		
		<cfset var Function = StructNew()/>
		
		<cfset Function.dateTimeString = zuluDateTimeFormat(Now())/>
		
		<cfif IsDefined("Arguments.numberOfMessages")>
			<cfset Function.numberOfMessagesPair = "NumberOfMessages#Arguments.numberOfMessages#"/>
		<cfelse>
			<cfset Function.numberOfMessagesPair = ""/>
		</cfif>
		
		<cfif IsDefined("Arguments.visibilityTimeout")>
			<cfset Function.visibilityTimeoutPair = "VisibilityTimeout#Arguments.visibilityTimeout#"/>
		<cfelse>
			<cfset Function.visibilityTimeoutPair = ""/>
		</cfif>
		
		<!--- Build signature string --->
		
		<cfset Function.fixedData = "ActionReceiveMessage" &
									"AWSAccessKeyId#This.awsAccessKeyId#" &
									Function.numberOfMessagesPair &
									"SignatureVersion1" &
									"Timestamp#Function.dateTimeString#" &
									"Version#This.sqsVersion#" &
									Function.visibilityTimeoutPair/>
		
		<cfset Function.signature = createSignature(Function.fixedData)/>
		
		<cfhttp method="GET" url="#Arguments.uri#" charset="UTF-8">
			<cfhttpparam type="url" name="Action" value="ReceiveMessage"/>
			<cfhttpparam type="url" name="AWSAccessKeyId" value="#This.awsAccessKeyId#"/>
			<cfif IsDefined("Arguments.numberOfMessages")>
				<cfhttpparam type="url" name="NumberOfMessages" value="#Arguments.numberOfMessages#"/>
			</cfif>
			<cfhttpparam type="url" name="Signature" value="#Function.signature#"/>
			<cfhttpparam type="url" name="SignatureVersion" value="1"/>
			<cfhttpparam type="url" name="Timestamp" value="#Function.dateTimeString#"/>
			<cfhttpparam type="url" name="Version" value="#This.sqsVersion#"/>
			<cfif IsDefined("Arguments.visibilityTimeout")>
				<cfhttpparam type="url" name="VisibilityTimeout" value="#Arguments.visibilityTimeout#"/>
			</cfif>
		</cfhttp>
		
		<cfif CFHTTP.ResponseHeader.Status_Code neq 200>
			<cfinvoke method="handleErrors"
				content="#CFHTTP.FileContent#"
			/>
		<cfelse>
			<cfset Function.messageNode = XmlSearch(CFHTTP.FileContent, "//:Message")/>

			<cfset Function.messages = ArrayNew(1)/>
			
			<cfset Function.messageNodeCount = ArrayLen(Function.messageNode)/>
			
			<cfloop index="i" from="1" to="#Function.messageNodeCount#">
				<cfset Function.message = StructNew()/>
				
				<cfset Function.message.id = Function.messageNode[i].MessageId.XmlText/>
				<cfset Function.message.body = Function.messageNode[i].MessageBody.XmlText/>	
				
				<cfset Function.messages[i] = Function.message/>
			</cfloop>
			
			<cfreturn Function.messages/>
		</cfif>
	</cffunction>
	
	<cffunction name="removeGrant" output="false" returntype="void"> <!--- TODO: Test --->
		<cfargument name="uri" type="string" required="true"/>
		<cfargument name="queueName" type="string" required="true"/>
		<cfargument name="granteeEmailAddress" type="string" required="false"/>
		<cfargument name="granteeId" type="string" required="false"/>
		<cfargument name="permission" type="string" required="true"/>
		
		<cfset var Function = StructNew()/>
		
		<cfset Function.dateTimeString = zuluDateTimeFormat(Now())/>
		
		<!--- Build signature string --->
		
		<cfif IsDefined("Arguments.granteeEmailAddress")>
			<cfset Function.granteeEmailAddressPair = "Grantee.EmailAddress#Arguments.granteeEmailAddress#"/>
		<cfelse>
			<cfset Function.granteeEmailAddressPair = ""/>
		</cfif>
		
		<cfif IsDefined("Arguments.granteeId")>
			<cfset Function.granteeIdPair = "Grantee.ID#Arguments.granteeId#"/>
		<cfelse>
			<cfset Function.granteeIdPair = ""/>
		</cfif>
		
		<cfset Function.fixedData = "ActionRemoveGrant" &
									"AWSAccessKeyId#This.awsAccessKeyId#" &
									Function.granteeEmailAddressPair &
									Function.granteeIdPair &
									"Permission#Arguments.permission#" &
									"QueueName#Arguments.queueName#" &
									"SignatureVersion1" &
									"Timestamp#Function.dateTimeString#" &
									"Version#This.sqsVersion#"/>
		
		<cfset Function.signature = createSignature(Function.fixedData)/>
		
		<cfhttp method="GET" url="#Arguments.uri#" charset="UTF-8">
			<cfhttpparam type="url" name="Action" value="RemoveGrant"/>
			<cfhttpparam type="url" name="AWSAccessKeyId" value="#This.awsAccessKeyId#"/>
			<cfif IsDefined("Arguments.granteeEmailAddress")>
				<cfhttpparam type="url" name="Grantee.EmailAddress" value="#Arguments.granteeEmailAddress#"/>
			</cfif>
			<cfif IsDefined("Arguments.granteeId")>
				<cfhttpparam type="url" name="Grantee.ID" value="#Arguments.granteeId#"/>
			</cfif>
			<cfhttpparam type="url" name="Permission" value="#Arguments.permission#"/>
			<cfhttpparam type="url" name="QueueName" value="#Arguments.queueName#"/>
			<cfhttpparam type="url" name="Signature" value="#Function.signature#"/>
			<cfhttpparam type="url" name="SignatureVersion" value="1"/>
			<cfhttpparam type="url" name="Timestamp" value="#Function.dateTimeString#"/>
			<cfhttpparam type="url" name="Version" value="#This.sqsVersion#"/>
		</cfhttp>
		
		<cfif CFHTTP.ResponseHeader.Status_Code neq 200>
			<cfinvoke method="handleErrors"
				content="#CFHTTP.FileContent#"
			/>
		</cfif>
	</cffunction>
	
	<cffunction name="sendMessage" output="false" returntype="string">
		<cfargument name="uri" type="string" required="true"/>
		<cfargument name="messageBody" type="string" required="true"/>
		
		<cfset var Function = StructNew()/>
		
		<!--- NOTE: We're using the REST interface in this method because the query interface limits message sizes to 8 kB rather than 256 kB --->
		
		<cfset Function.dateTimeString = GetHTTPTimeString(Now())/>
		
		<!--- Build path --->
		
		<cfset Function.path = Right(Arguments.uri, Len(Arguments.uri) - Len(This.serviceUrl))/>
		
		<!--- Build signature string --->
		
		<cfset Function.cs = "PUT\n" &
							 "\n" &
							 "text/plain\n" &
							 "#Function.dateTimeString#\n" & 
							 "#Function.path#/back"/>
		<cfset Function.fixedData = Replace(Function.cs, "\n", Chr(10), "all")/>
		
		<cfset Function.signature = createSignature(Function.fixedData)/>
		
		<cfhttp method="PUT" url="#Arguments.uri#/back" charset="UTF-8">
			<cfhttpparam type="header" name="Authorization" value="AWS #This.awsAccessKeyId#:#Function.signature#"/>
			<cfhttpparam type="header" name="AWS-Version" value="#This.sqsVersion#"/>
			<cfhttpparam type="header" name="Content-Type" value="text/plain"/>
			<cfhttpparam type="header" name="Date" value="#Function.dateTimeString#"/>
			<cfhttpparam type="body" value="#Arguments.messageBody#"/>
		</cfhttp>
		
		<cfif CFHTTP.ResponseHeader.Status_Code neq 200>
			<cfinvoke method="handleErrors"
				content="#CFHTTP.FileContent#"
			/>
		<cfelse>
			<cfset Function.messageIds = XmlSearch(CFHTTP.FileContent, "//:MessageId")/>
			
			<cfreturn Function.messageIds[1].XmlText/>
		</cfif>
	</cffunction>
	
	<cffunction name="setQueueAttributes" output="true" returntype="void"> <!--- TODO: Test --->
		<cfargument name="uri" type="string" required="true"/>
		<cfargument name="attribute" type="string" required="true"/>
		<cfargument name="value" type="string" required="true"/>
		
		<cfset var Function = StructNew()/>
		
		<cfset Function.dateTimeString = zuluDateTimeFormat(Now())/>
		
		<!--- Build signature string --->
		
		<cfset Function.fixedData = "ActionSetQueueAttributes" &
									"Attribute#Arguments.attribute#" &
									"AWSAccessKeyId#This.awsAccessKeyId#" &
									"SignatureVersion1" &
									"Timestamp#Function.dateTimeString#" &
									"Value#Arguments.value#" &
									"Version#This.sqsVersion#"/>

		<cfset Function.signature = createSignature(Function.fixedData)/>
		
		<cfhttp method="GET" url="#Arguments.uri#" charset="UTF-8">
			<cfhttpparam type="url" name="Action" value="SetQueueAttributes"/>
			<cfhttpparam type="url" name="Attribute" value="#Arguments.attribute#"/>
			<cfhttpparam type="url" name="AWSAccessKeyId" value="#This.awsAccessKeyId#"/>
			<cfhttpparam type="url" name="Signature" value="#Function.signature#"/>
			<cfhttpparam type="url" name="SignatureVersion" value="1"/>
			<cfhttpparam type="url" name="Timestamp" value="#Function.dateTimeString#"/>
			<cfhttpparam type="url" name="Value" value="#Arguments.value#"/>
			<cfhttpparam type="url" name="Version" value="#This.sqsVersion#"/>
		</cfhttp>
		
		<cfif CFHTTP.ResponseHeader.Status_Code neq 200>
			<cfinvoke method="handleErrors"
				content="#CFHTTP.FileContent#"
			/>
		</cfif>
	</cffunction>
	
	<cffunction name="zuluDateTimeFormat" output="false" returntype="string" access="private">
		<cfargument name="dateTime" type="date" required="true"/>
		
		<cfset var Function = StructNew()/>
		
		<cfset Function.utcDate = DateAdd("s", GetTimeZoneInfo().utcTotalOffset, Arguments.dateTime)/>
		
		<cfreturn DateFormat(Function.utcDate, "yyyy-mm-dd") & "T" & TimeFormat(Function.utcDate, "HH:mm:ss.l") & "Z"/>
	</cffunction>

</cfcomponent>

