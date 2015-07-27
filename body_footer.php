<!--  Segunda tag comScore -->
<!-- - The UDM comScore Tag consists of two code snippets. Please include both code snippets in your web pages. part 2/2-->
<script type="text/javascript" language="JavaScript1.3" src="http://b.scorecardresearch.com/c2/7672308/ct.js"></script>

<!-- Segunda tag Adobe DTM -->    
<script type="text/javascript">_satellite.pageBottom();</script>

<?php if( (isset($OAS_SITEPAGE) && !empty($OAS_SITEPAGE)) && (isset($OAS_LISTPOS) && !empty($OAS_LISTPOS)) ): ?>
<!--RealMedia -->
<script src="http://www.estadao.com.br/estadao/js/modules/AdBanner.js"></script>
<script type="text/javascript">
	try{ oas_nvg_qry = NVG_qry; } catch(ex){ oas_nvg_qry = ""; }
	var oBanner = new Banner({
		sitepage:"<?php echo $OAS_SITEPAGE;?>",
		listpos:"<?php echo $OAS_LISTPOS;?>",
		query:oas_nvg_qry
	});
</script>
<?php 
	function OAS_MJX($pos = null){
		if(empty($pos))
			return false;
		
		$pos = explode(",",$pos);
		$callBanners = "";
		
		foreach($pos as $p) {
			$callBanners .= "<div id=\"Hidden_OAS_".$p."\" style=\"display: none !important;\">";
			$callBanners .= "<scr"."ipt>oBanner.OAS_AD('".$p."')</scr"."ipt>";
			$callBanners .= "</div>";		
		}
		
		//escreve banners
		echo $callBanners;
	}
	
	//Append Banners
	echo "<script>oBanner.appendDivsBanners();</script>";
	OAS_MJX($OAS_LISTPOS);
endif; ?>