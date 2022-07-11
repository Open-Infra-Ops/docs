SBOM元数据定义参考


业界如何定义SBOM：
Table 1 	SBOM最小集(Minimum Elements)
数据字段 Data Fields-baseline attributes	Supplier Name：author of the SBOM
Timestamp：date and time when the SBOM was last updated
Supplier Name：name or other identifier of the supplier of a component in an SBOM entry
Component Name：name or other identifier of a component
Version String ：version of a component
Component Hash：cryptographic hash of a component
Component Hash is a recommended, but not required, Data Field element in The Minimum Elements For a Software Bill of Materials (SBOM). 
Unique Identifier :additional information to help uniquely define a componen
Relationship: association between SBOM components
自动化支持 Automation Support	1、	自动化产生SBOM、跨软件供应链机器可读
2、	Data formats：include SPDX, CycloneDX, and SWID tags.
过程实践 Practices and Process	定义SBOM的产生与应用，包括：频度、深度、发布与交付、获取控制、典型应用等.


Formats		SPDX	SWID	CycloneDX
组织	Linux Fundation	ISP&IEC	OWASP
标准化	ISO/IEC 5962	ISO/IEC 19770-2	https://cyclonedx.org/docs/1.2
SBOM最小集	支持	支持	支持
主要应用场景	开源社区OpenChain 合规场景	软件标识：安装、部署、补丁、移除	开源管理、漏洞、合规等场景
尽管SPDX/SWID/CyCloneDX均能用于SBOM具体格式实现，但只有CycloneDX是full-stack SBOM standard设计，且数据的基本机制+扩展机制可以满足华为应用场景，其完整的工程采集机制，可以实现基于构建的自动化SBOM。
 
NTIA定义的SBOM最小集（8要素）以及三种组织支持SBOM的格式标准如下： 
 


 

业界提出来使用PURL（Package URL）作为统一不同生态系统的软件标识。该社区标准已经被包括SPDX，CycloneDX等社区采用。

华为SwBOM- 在最小集之外加额外相关信息：
华为SwBOM中软件标识采用业界CycloneDX引用的规范PURL，格式定义如下：
scheme:type/namespace/name@version?qualifiers#subpath
 

SwBOM存档的文件名规范
建议SwBOM存档为对应的软件包名+_UUID_SwBOM.json，例如：
xxxxx_UUID_SwBOM.json


SwBOM数据来源
信息树的数据采集分为成分信息（SwBOM）以及成分的详情信息采集。
SwBOM各字段的数据来源总结如下：
 



基于构建产生SwBOM
SwBOM的生成过程如下：
 

基于编辑生成
通过将存量设计树产生的依赖关系转成SwBOM格式统一接入SwBOM数据中心，可以利用SwBOM的中心服务对设计态的C版本进行漏洞追溯。
新的设计树，信息树3.0目标是采用新的SwBOM格式。
 





