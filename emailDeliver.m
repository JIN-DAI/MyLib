function emailDeliver(subject, content, attachment)
%% send a email to 163 email box
if nargin < 3
    attachment = [];
end
if nargin < 2
    content='This is a test email sent by MATLAB!';
end
if nargin < 1
    subject='test mail';
end

% information about email account
MailAddress='daijinghub@163.com';
password='Dhamiria491';

% setting email service
setpref('Internet','E_mail',MailAddress);
setpref('Internet','SMTP_Server','smtp.163.com');
setpref('Internet','SMTP_Username',MailAddress);
setpref('Internet','SMTP_Password',password);
props=java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','994');

% send email
if isempty(attachment)
    sendmail('daijinghub@163.com',subject,content);
else
    sendmail('daijinghub@163.com',subject,content,attachment);
end
    
end