{{ 
  (() => {
    let template = $('env').first().json.prompt['intent-agent']['user-prompt'];
    const need_image_agent = $('Code in JavaScript1').first().json.need_image_agent;
    let ask = $('Code in JavaScript1').first().json.ask;
    if(need_image_agent) {
      ask = $('image-qus').first().json.ask || "hello"
    }
    const dataMap = {
      '{channel}': $json.channel,
      '{login_status}': $('Code in JavaScript1').first().json.isLogin,
      '{user_profile}': $('Code in JavaScript10').first().json.user_profile || '无',
      '{recent_dialogue}': $('Code in JavaScript').first().json.history_context || '无',
      '{user_query}': ask
  };
    for (const [placeholder, value] of Object.entries(dataMap)) {
      const safeValue = value ? value.toString() : ''; 
      template = template.replaceAll(placeholder, safeValue);
    }
    return template;
  })()
}}