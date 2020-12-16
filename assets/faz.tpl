Content-Type: multipart/mixed; boundary="===============0086047718136476635=="
MIME-Version: 1.0

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system admin setting
set https_port 34443
set idle_timeout 120
set gui-theme zebra
end

config system global
set hostname ${hostname}
set timezone 57
end

config system interface
edit port1
set alias public
set mode static
set ip ${Port1IP}/${public_subnet_mask}
set serviceaccess fclupdates fgtupdates webfilter-antispam
set allowaccess ping https ssh
next

config system route
edit 0
set dst 0.0.0.0/0
set device port1
set gateway  ${gateway}
next

%{ if vm_type == "fmg" }
config fmupdate service
set avips enable
set query-antispam enable
set query-antivirus enable
set query-filequery enable
set query-outbreak-prevention enable
set query-webfilter enable
set webfilter-https-traversal enable
end 
%{ endif }


%{ if vm_license_file != "" }
--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="${vm_license_file}"

${file(vm_license_file)}

%{ endif }
--===============0086047718136476635==--