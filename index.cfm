<cfparam name="action" default=""/>

<cfset awsAccessKeyId = "[Your access key ID here]"/>
<cfset secretAccessKey = "[Your secret access key ID here]"/>

<cfset sqs = CreateObject("component", "sqs").init(awsAccessKeyId, secretAccessKey)/>

<cfswitch expression="#action#">
	<cfcase value="createQueue">
		<cfset sqs.createQueue(Form.queueName)/>
	</cfcase>
	<cfcase value="deleteQueue">
		<cfset sqs.deleteQueue(Url.queueUri)/>
	</cfcase>
	<cfcase value="sendMessage">
		<cfset sqs.sendMessage(Form.queueUri, Form.message)/>
	</cfcase>
	<cfcase value="receiveMessage">
		<cfset msg = sqs.receiveMessage(Url.queueUri)/>
		<cfdump var="#msg#"/>
	</cfcase>
	<cfcase value="peekMessage">
		<cfset msg = sqs.peekMessage(Url.queueUri, Url.messageId)/>
	</cfcase>
	<cfcase value="receiveAndDelete">
		<cfset msg = sqs.receiveMessage(Url.queueUri)/>
		<cfdump var="#msg#"/>
		<cfif msg.id is not "0">
			<cfset sqs.deleteMessage(Url.queueUri, msg.id)/>
		</cfif>
	</cfcase>
	<cfcase value="peekAndDelete">
		<cfset msg = sqs.peekMessage(Url.queueUri, Url.messageId)/>
		<cfset sqs.deleteMessage(Url.queueUri, Url.messageId)/>	
	</cfcase>
	<cfcase value="listGrants">
		<cfdump var="#sqs.listGrants(Url.queueUri, Url.queueName)#"/>
	</cfcase>
	<cfcase value="getQueueAttributes">
		<cfdump var="#sqs.getQueueAttributes(Url.queueUri, Url.attribute)#"/>
	</cfcase>
</cfswitch>

<style type="text/css">
	body, table {
		font-family: Lucida Grande, Segoe UI, Tahoma, Arial, Helvetica, sans-serif;
		font-size: 13px;
	}
	table {
		border-collapse: collapse;
	}
	table td, table th {
		padding: 6px;
		border: 1px solid #898989;
	}
</style>

<cfoutput>

	<h1><a href="#CGI.SCRIPT_NAME#">Amazon Simple Queue Service</a></h1>
	
	<h2>Queues</h2>

	<cfset queues = sqs.listQueues()/>

	<cfset queueCount = ArrayLen(queues)/>
	
	<table summary="">
		<thead>
			<tr>
				<th>Queue URL</th>
				<th colspan="5">
					Actions
				</th>
			</tr>
		</thead>
		<tbody>
			<cfloop index="i" from="1" to="#queueCount#">
				<tr>
					<td>#queues[i]#</td>
					<td>
						<a href="#CGI.SCRIPT_NAME#?action=getQueueAttributes&amp;queueUri=#queues[i]#&amp;attribute=All">Get Attributes</a>
					</td>
					<td>
						<a href="#CGI.SCRIPT_NAME#?action=listGrants&amp;queueUri=#queues[i]#&amp;queueName=#ListLast(queues[i], '/')#">List Grants</a>
					</td>
					<td>
						<a href="#CGI.SCRIPT_NAME#?action=deleteQueue&amp;queueUri=#queues[i]#">Delete Queue</a>
					</td>
					<td>
						<a href="#CGI.SCRIPT_NAME#?action=receiveMessage&amp;queueUri=#queues[i]#">Receive Message</a>
					</td>
					<td>
						<a href="#CGI.SCRIPT_NAME#?action=receiveAndDelete&amp;queueUri=#queues[i]#">Receive and Delete Message</a>
					</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
	
	<h2>Create Queue</h2>

	<form action="#CGI.SCRIPT_NAME#" method="post">
		<label for="queueName">Queue name</label> <input type="text" name="queueName" id="queueName"/>
		<input type="hidden" name="action" value="createQueue"/>
		<input type="submit" value="Create Queue"/>
	</form>
	
	<h2>Send Message</h2>
	
	<form action="#CGI.SCRIPT_NAME#" method="post">
		<label for="queueUri">Queue</label>
		<select name="queueUri" id="queueUri">
			<cfloop index="i" from="1" to="#queueCount#">
				<option value="#queues[i]#">#ListLast(queues[i], "/")#</option>
			</cfloop>
		</select>
		<br/>
		<label for="message">Message</label>
		<br/>
		<textarea name="message" id="message" rows="20" cols="50"></textarea>
		<br/>
		<input type="hidden" name="action" value="sendMessage"/>
		<input type="submit" value="Send"/>
	</form>

</cfoutput>
