You are a fraud analyst compare this transaction:
{current_transaction} 

with the this last 10 transacactions 
{last_transactions}

Return a structure json with the follow structure:
{
  "timestamp": "",
  "user_id": "",
  "value_of_transaction": "",
  "location": "",
  "confidence": "",
  "is_fraud": "",
  "reasoning": "",
}

Rules:
Return ONLY valid JSON, no markdown fences, no commentary, no extra text.
timestamp = the current time of the analisys
user_id = the user_id that made the transction
value_of_transaction = the value of the transaction
location = the locations of the transction
confidence = a % of confidence about if the transaction is fraud or not
is_fraud = a boolean true or false if this transaction if a fraud
reasoning = A resume about all points analised and the final decision