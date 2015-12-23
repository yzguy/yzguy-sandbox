mport smtplib
import csv
from email.mime.text import MIMEText

username = ''
password = ''
fromaddr = ''

f = open('email.csv', 'r')
reader = csv.reader(f, delimiter=',')

def send_mail(email, name, company, optional, promo):
 body = """
Hello %s,

I'm contacting you regarding a new app that we are going to be releasing in a couple of days. We would love it if %s would review our app. Please contact me for more details.\n""" % (name, company)

 if (not optional):
    body += """
%s
  """ % optional

 if (not promo):
    body += """
    %s
  """ % promo

 body += """
Thanks,
John Doe  
 """ 

 msg = MIMEText(body)
 msg['Subject'] = 'Test Email'
 msg['From'] = fromaddr
 msg['To'] = email

 print msg
 print "" 
   
 server = smtplib.SMTP("smtp.gmail.com:587")
 server.starttls()
 server.login(username, password)
 server.sendmail(fromaddr, [email], msg.as_string())
 server.close()

for i in reader:
    send_mail(i[0], i[1], i[2], i[3], i[4])






