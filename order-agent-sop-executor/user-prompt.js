{{ 
  (() => {
    let template = $('env').first().json.prompt['order-agent-sop-executor']['user-prompt'];
    const now = new Date().toISOString();
    const need_image_agent = $('Code in JavaScript1').first().json.need_image_agent;
    let ask = $('Code in JavaScript1').first().json.ask;
    if(need_image_agent) {
      ask = $('image-qus').first().json.ask || "hello"
    }
    const dataMap = {
      '{channel}': $('Code in JavaScript13').first().json.channel,
      '{login_status}': $('Code in JavaScript13').first().json.login_status,
      '{target_language}': $('Code in JavaScript13').first().json.target_language,
      '{language_code}': $('Code in JavaScript13').first().json.language_code,
      '{user_profile}': $('Code in JavaScript13').first().json.user_profile || '无',
      '{active_context}': $('Code in JavaScript13').first().json.active_context || '无',
      '{recent_dialogue}': $('Code in JavaScript13').first().json.recent_dialogue || '无',
      '{tvcmall_web_baseUrl}': $('Code in JavaScript13').first().json.tvcmall_web_baseUrl || '无',
      '{user_query}': ask,
      '{current_system_time}': now
  };
    for (const [placeholder, value] of Object.entries(dataMap)) {
      const safeValue = value ? value.toString() : ''; 
      template = template.replaceAll(placeholder, safeValue);
    }
    return template;
  })()
}}