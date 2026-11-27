class_name AiClient
extends Node
## Talks only to the project's backend. Provider credentials never enter the client.

const MAX_REPLY_LENGTH := 700


func request_async(message: String, context: Dictionary) -> Dictionary:
	if not Settings.ai_enabled:
		return {"ok": false, "error": "AI disabled"}
	var endpoint := Settings.sanitize_endpoint(Settings.ai_endpoint)
	var session := await _post_json(endpoint + "/v1/session", {"install_id": Settings.install_id}, {})
	if not session.get("ok", false):
		return session
	var token := String(session.get("data", {}).get("token", ""))
	if token.is_empty():
		return {"ok": false, "error": "Backend did not issue a session"}
	var payload := {"message": message, "context": context}
	var response := await _post_json(endpoint + "/v1/conversation", payload, {"Authorization": "Bearer " + token})
	if not response.get("ok", false):
		return response
	var reply := String(response.get("data", {}).get("reply", "")).strip_edges()
	if not _safe_reply(reply):
		return {"ok": false, "error": "Response failed client-side safety validation"}
	return {"ok": true, "reply": reply, "source": String(response.get("data", {}).get("source", "ai"))}


func _post_json(url: String, payload: Dictionary, headers: Dictionary) -> Dictionary:
	var http := HTTPRequest.new()
	http.timeout = 15.0
	http.use_threads = true
	add_child(http)
	var request_headers: PackedStringArray = ["Content-Type: application/json"]
	for key in headers:
		request_headers.append("%s: %s" % [key, headers[key]])
	var body := JSON.stringify(payload)
	var error := http.request(url, request_headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		http.queue_free()
		return {"ok": false, "error": "Could not contact backend"}
	var result: Array = await http.request_completed
	var status := int(result[1])
	var response_body := result[3] as PackedByteArray
	http.queue_free()
	if status < 200 or status >= 300:
		return {"ok": false, "error": "Backend returned HTTP %d" % status, "status": status}
	var parsed: Variant = JSON.parse_string(response_body.get_string_from_utf8())
	if not parsed is Dictionary:
		return {"ok": false, "error": "Backend returned invalid JSON"}
	return {"ok": true, "data": parsed}


func _safe_reply(reply: String) -> bool:
	if reply.is_empty() or reply.length() > MAX_REPLY_LENGTH:
		return false
	if "<" in reply or ">" in reply or "http://" in reply or "https://" in reply:
		return false
	var lowered := reply.to_lower()
	for phrase in ["api key", "system prompt", "as an ai", "ignore your instructions", "relationship score"]:
		if phrase in lowered:
			return false
	return true
