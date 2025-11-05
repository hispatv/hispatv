from Screens.Screen import Screen
from Components.Label import Label
from Plugins.Plugin import PluginDescriptor
from Components.ActionMap import ActionMap
from Screens.MessageBox import MessageBox
import urllib.request
import subprocess
import json
import time
import os


class HispaTVManager(Screen):
    skin = """
        <screen name="HispaTVManager" position="center,center" size="600,400" title="HispaTV Manager">
            <widget name="eid_label" position="50,30" size="500,50" font="Regular;24" halign="left" valign="center" />
            <widget name="active_label" position="50,70" size="500,50" font="Regular;24" halign="left" valign="center" />
            <widget name="active_sublabel" position="50,270" size="500,50" font="Regular;20" halign="left" valign="center" />
            <!-- Indicador rojo -->
            <widget name="update_label" position="50,330" size="30,30" font="Regular;20" backgroundColor="#FF0000" halign="center" valign="center" />
            <widget name="update_text" position="90,330" size="200,30" font="Regular;20" halign="left" valign="center" />
            <!-- Indicador verde -->
            <widget name="reboot_label" position="190,330" size="30,30" font="Regular;20" backgroundColor="#00FF00" halign="center" valign="center" />
            <widget name="reboot_text" position="230,330" size="200,30" font="Regular;20" halign="left" valign="center" />
            <!-- Indicador amarillo -->
            <widget name="contact_label" position="330,330" size="30,30" font="Regular;20" backgroundColor="#FFFF00" halign="center" valign="center" />
            <widget name="contact_text" position="370,330" size="100,30" font="Regular;20" halign="left" valign="center" />
            <!-- Version -->
            <widget name="version_label" position="500,330" size="60,30" font="Regular;16" backgroundColor="#3B3B3B" halign="center" valign="center" />
            
        </screen>
    """

    def __init__(self, session):
        Screen.__init__(self, session)
        
        version = "1.0.2"
        self["version_label"] = Label("v" + version)  # version

        self["eid_label"] = Label(f"Obtaining EID...")
        eid = self.getEID()
        self["eid_label"].setText(f"EID: {eid}")

        self["update_label"] = Label(" ")  # cuadrado rojo
        self["update_text"] = Label("Reboot")  # texto rojo
        

        self["actions"] = ActionMap(
            ["OkCancelActions", "ColorActions"],
            {
                "cancel": self.close,
                "red": self.rebootPressed,
                "green": self.updatePressed,
                "yellow": self.supportPressed
            },
            -1
        )

        self["active_label"] = Label(f"Obtaining activation status...")

        status = self.getDeviceStatus(eid)
        if status is None:
            self["active_label"].setText("Error obtaining status. Check your connection or retry later.")
        else:
            active = status.get("active", None)
            if active is True:
                self["active_label"].setText("Your DEVICE is ACTIVE")
                
                timestamp = int(status.get("exp_date", "0"))
                date = time.strftime("%d/%m/%Y %H:%M", time.localtime(timestamp))
                self["active_sublabel"] = Label("Activation valid until: " + date)

                self["reboot_label"] = Label(" ")  # cuadrado verde
                self["reboot_text"] = Label("Update")  # texto verde

                self["contact_label"] = Label(" ")  # cuadrado amarillo
                self["contact_text"] = Label("Contact")  # texto amarillo
                
            if active is False:
                self["active_label"].setText("Your DEVICE is INACTIVE")
            if active is None:
                self["active_label"].setText("Unknown activation status.")
            
        



    def getEID(self):
        try:
            with open("/sys/class/net/eth0/address", "r") as f:
                mac = f.readline().strip()
            clean_mac = mac.replace(":", "").upper()
            return f"HPL0{clean_mac}"
        except Exception as e:
            return "No EID found. Contact support."
    
    def getDeviceStatus(self, eid):
        try:
            url = f"https://e2manager.hispacam.workers.dev/enigma2/{eid}"
            
            with urllib.request.urlopen(url, timeout=5) as respuesta:
                datos = json.loads(respuesta.read().decode())
                return datos
        except Exception as e:
            return None
    
    def rebootPressed(self):
        # Confirmación antes de reiniciar
        self.session.openWithCallback(self.confirmReboot, MessageBox, "Reboot device?", MessageBox.TYPE_YESNO)

    def confirmReboot(self, result):
        if result:
            os.system("reboot")
    
    def updatePressed(self):
        self.session.openWithCallback(self.confirmUpdate, MessageBox, "Update plugin and download the last bouquet/epg?", MessageBox.TYPE_YESNO)
    
    def confirmUpdate(self, result):
        if result:
            script_path = "/usr/lib/enigma2/python/Plugins/Extensions/HispaTV/update.sh"
            log_path = "/tmp/hispatv_update.log"

            try:
                # Asegura permisos de ejecución
                os.chmod(script_path, 0o755)

                # Abre el log para escritura
                with open(log_path, "w") as log_file:
                    # Ejecuta con entorno limpio pero funcional
                    result_code = subprocess.call(
                        [
                            "/usr/bin/env",
                            "-i",
                            "PATH=/bin:/usr/bin:/sbin:/usr/sbin",
                            "/bin/sh",
                            script_path
                        ],
                        stdout=log_file,
                        stderr=subprocess.STDOUT
                    )

                # Lee el log después de finalizar
                with open(log_path, "r") as log_file:
                    log_content = log_file.read()

                # Muestra resultado y últimas líneas del log
                if result_code == 0:
                    self.session.open(
                        MessageBox,
                        "✅ Update completed successfully!\n\nLast log lines:\n\n" + log_content[-400:],
                        type=MessageBox.TYPE_INFO,
                        timeout=15
                    )
                else:
                    self.session.open(
                        MessageBox,
                        f"⚠️ Update failed (exit code {result_code})\n\nLog excerpt:\n\n{log_content[-400:]}",
                        type=MessageBox.TYPE_ERROR,
                        timeout=20
                    )

            except Exception as e:
                self.session.open(
                    MessageBox,
                    f"Error executing update script:\n{str(e)}",
                    type=MessageBox.TYPE_ERROR,
                    timeout=10
                )
    
    def supportPressed(self):
        self.session.open(
            MessageBox,
            "Contact support at:\nhttps://t.me/hispateuve",
            type=MessageBox.TYPE_INFO,
            timeout=10
        )



def main(session, **kwargs):
    session.open(HispaTVManager)


def Plugins(**kwargs):
    return PluginDescriptor(
        name="HispaTV Manager",
        description="Official HispaTV Manager Plugin",
        where=PluginDescriptor.WHERE_PLUGINMENU,
        icon="plugin.png",
        fnc=main
    )