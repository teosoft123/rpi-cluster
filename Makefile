install:
	helm install \
		-f ./local.values.yaml \
		bgvault -n bgvault \
		.

upgrade:
	helm upgrade \
		-f ./local.values.yaml \
		bgvault -n bgvault \
		.

uninstall:
	helm uninstall bgvault -n bgvault

update:
	helm dependencies update

# ArgoCD

create_argocd_namespace:
	kubectl create namespace argocd || true

install_argocd:
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

patch_argocd_for_ui_access:
	kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Using kubectl to get initial password for user admin
show_argocd_connection_and_creds:

	@printf "\nArgoCD URL is https://%s\n" $(shell kubectl get svc/argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
	@echo "\nIf you cannot connect using the above URL, examine the output of the following command:\n"
	kubectl get svc argocd-server -n argocd

	@printf "\nArgoCD password for user admin is: %s\n" $(shell kubectl get secret/argocd-initial-admin-secret -n argocd --template={{.data.password}} | base64 -d)
	@echo "\n+++Please change admin password after login+++\n"

argocd: create_argocd_namespace install_argocd patch_argocd_for_ui_access show_argocd_connection_and_creds

# Linkerd
install_linkerd_cli:
	curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
	@echo 'Please add the following to your .bashrc or .zshrc:'
	@echo 'export PATH=$$HOME/.linkerd2/bin:$$PATH'

install_linkerd_crd:
	linkerd install --crds | kubectl apply -f -

install_linkerd_cni:
	linkerd install-cni --dest-cni-bin-dir /usr/libexec/cni/ | kubectl apply -f -

linkerd_pre_check:
	linkerd check --linkerd-cni-enabled --pre

install_linkerd: linkerd_pre_check
	linkerd install --linkerd-cni-enabled | kubectl apply -f -

install_linkerd_without_cni:
	linkerd install | kubectl apply -f -

uninstall_linkerd:
	linkerd uninstall | kubectl delete -f -

unistall_linkerd_cni:
	linkerd install-cni | kubectl delete -f -

linkerd_check:
	linkerd check

install_linkerd_viz:
	linkerd viz install | kubectl apply -f -
	@make linkerd_check

run_linkerd_viz:
	linkerd viz dashboard &

linkerd: install_linkerd_crd install_linkerd_cni install_linkerd linkerd_check
