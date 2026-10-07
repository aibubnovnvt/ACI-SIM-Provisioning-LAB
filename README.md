# ACI-SIM Provisioning LAB

ACI-SIM provisioning lab scripts. This project provisions an ACI-SIM fabric from scratch via Ansible and makes it
available for integration with the other components of the network.

---

## Step-by-Step: Running the Automation

1. Get to the Automation server (`root`/`C1sco12345`).
2. Pull down the project from git:
   ```bash
   git clone https://github.com/aibubnovnvt/ACI-SIM-Provisioning-LAB.git .
   ```
3. `cd` into the project folder.
4. Execute environment setup:
   ```bash
   ./setup_env.sh
   ```
5. Activate the venv environment created by the script:
   ```bash
   source venv/bin/activate
   ```
6. Open the ESXi (APIC) host GUI - the ACI-SIM VM is not yet running. Open the VM's main console page.
7. Go to the `POD1_config` folder. Find the aggregated playbook named `ACI_Simulator_Site.yml`.
8. Run the playbook and keep track of execution:
   ```bash
   cd POD1_config
   env https_proxy= ansible-playbook -i POD1 ACI_Simulator_Site.yml
   ```
9. The first series of tasks starts the ACI-SIM VM, then pauses execution for ~400 seconds to let the ACI VM load. The VM is loaded and ready for the next set of tasks only when its CLI state reaches the ACI topology selection prompt (small topology is selected automatically). This pause is crucial for the setup wizard on the ACI-SIM console to proceed correctly.
10. Once ACI-SIM console provisioning is done, the play pauses for another 400 seconds to let the VM fully boot and become reachable over HTTPS for the remaining API-driven stages.
11. Review the play recap at the end of the run to confirm all stages completed successfully.
12. To run the SPRT tool, Docker is required. From the `SPRT` folder at the project root, run:
    ```bash
    ./install_docker.sh
    docker --version
    ```
13. To start the SPRT containers:
    ```bash
    docker compose up -d
    ```

---

## Repository layout
```
.
├── .gitignore
├── .python-version
├── LICENSE
├── README.md
├── requirements.txt       # pip packages (Ansible + Python deps)
├── requirements.yml       # Ansible Galaxy collections
├── setup_env.sh           # bootstraps venv + installs everything above
├── SPRT/
│   ├── install_docker.sh                       # installs Docker CE (prerequisite for the SPRT containers)
│   └── docker-compose.yml                      # brings up the SPRT tool + its dependent services
└── POD1_config/
    ├── POD1                                       # inventory (hosts/vars for your lab)
    ├── ACI_Simulator_Site.yml                      # <- run this: orchestrates everything below in order
    ├── ACI_Simulator_Full.yml                      # VM boot + fabric registration
    ├── ACI_Simulator_Tenants.yml                   # tenants/VRFs/BDs/EPGs/contracts
    ├── ACI_Simulator_Networking.yml                # L3Outs / OSPF
    ├── ACI_Simulator_ESG.yml                       # Endpoint Security Groups
    ├── ACI_Simulator_HTTP_RPS_throttle.yml         # HTTP/HTTPS request throttling
    ├── ACI_Simulator_AccessPolicy_Bare_Metal.yml   # access policies for bare-metal ports
    ├── ACI_Simulator_DNS.yml                       # DNS provider/domain
    ├── EP_provisioning_bulk_5.sh                   # runs static_ep/*.py in order, fails fast
    ├── static_ep/                                  # bulk static-endpoint python scripts
    ├── ospf_area.j2                                # Jinja2 templates used by Networking.yml
    └── ospf_if_profile.j2
```
